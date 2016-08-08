require 'set'

class ComposersRecords

  def self.list(params)
    if params[:all_ids]
      resource_ids = collections_with_digital_objects_modified_since(params[:modified_since])
      ASUtils.to_json(resource_ids)
    elsif params[:id_set]
      # TODO: Other summary record types
      build_detailed_collection_records(params[:id_set])
    else
      raise "Unrecognized parameters: #{params.inspect}" unless params[:all_ids]
      nil
    end
  end

  private

  def self.collections_with_digital_objects_modified_since(modified_since)
    # Find any resource record that might be of interest
    query = Resource
            .any_repo
            .join(:archival_object, :archival_object__root_record_id => :resource__id)
            .left_join(:instance) { Sequel.|(Sequel.expr(Sequel.qualify(:instance, :resource_id) => Sequel.qualify(:resource, :id)),
                                             Sequel.expr(Sequel.qualify(:instance, :archival_object_id) => Sequel.qualify(:archival_object, :id)))}
            .join(:instance_do_link_rlshp, :instance_id => :instance__id)
            .join(:digital_object, :id => :instance_do_link_rlshp__digital_object_id)
            .where {(resource__system_mtime >= modified_since) |
                    (archival_object__system_mtime >= modified_since) |
                    (digital_object__system_mtime  >= modified_since)}
            .select(:resource__id)
            .distinct

    query.map {|row| row[:id]}
  end

  def self.build_detailed_collection_records(resource_ids)
    result = {}

    Resource.any_repo.filter(:id => resource_ids).select(:repo_id).distinct.each do |repo|
      RequestContext.open(:repo_id => repo[:repo_id]) do
        repo_resources = Resource.any_repo.filter(:id => resource_ids, :repo_id => repo[:repo_id]).all
        Resource.sequel_to_jsonmodel(repo_resources).each do |resource_json|
          result[resource_json.uri] = {
            'title' => resource_json.title,
            'identifier' => ASUtils.json_parse(resource_json.identifier).compact.join('.'),
            'bioghist_note' => resource_json.notes.select {|note| note['type'] == 'bioghist'},
            'scopecontent_note' => resource_json.notes.select {|note| note['type'] == 'scopecontent'},
            'archival_objects' => []
          }
        end

        repo_resources.each do |resource|
          aos_with_do_links = ArchivalObject
                              .this_repo
                              .filter(:root_record_id => resource.id)
                              .join(:instance, :instance__archival_object_id => :archival_object__id)
                              .join(:instance_do_link_rlshp, :instance_id => :instance__id)
                              .all

          ArchivalObject.sequel_to_jsonmodel(aos_with_do_links).each do |ao_json|
            summary_record = result.fetch(ao_json['resource']['ref'])

            summary_record['archival_objects'] << {
              'component_id' => ao_json.component_id,
              'title' => ao_json.display_string,
              'dates' => ao_json.dates,
              'phystech_note' => ao_json.notes.select {|note| note['type'] == 'bioghist'},
              'extent/phystech' => '?',
              'scopecontent_note' => ao_json.notes.select {|note| note['type'] == 'scopecontent'},
              'accessrestrict_note' => ao_json.notes.select {|note| note['type'] == 'accessrestrict'},
              'enduserestrict_note' => ao_json.notes.select {|note| note['type'] == 'enduserestrict'},
              'rights_statements' => ao_json.rights_statements,
              'linked_agents' => ao_json.linked_agents.map {|agent| agent.display_name},
            }
          end
        end
      end
    end

    ASUtils.to_json(result.values)
  end

  def self.resource_to_json(resource)
    {
      :identifier => [resource[:id_0], resource[:id_1], resource[:id_2], resource[:id_3]].compact.join("."),
      :title => resource.title,
      :notes => resource.notes,
    }
  end

end
