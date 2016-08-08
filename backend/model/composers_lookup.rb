class ComposersLookup

  RESOURCE_SUMMARY_TYPE = 'resource_summary'

  def self.detailed(resource_id)
    dataset.collect {|obj| obj[:id]}
  end


  def self.digital_objects(component_id)
    dataset.collect {|obj| obj[:id]}
  end


  def self.summary(resource_id)
    repositories.each do |repo_id|
      results = Search.search({:type => RESOURCE_SUMMARY_TYPE,
                               :filter_terms => ASUtils.to_json(['resource_id', resource_id]),
                               :page => 1,
                               :page_size => 1},
                              repo_id)

      return results
    end
  end


  private

  def self.repositories
    AppConfig[:composers_repository_ids].split(/\s*,\s*/)
      .compact
      .map {|repo_id| Integer(repo_id)}
  rescue
    Log.exception("Failed to parse your list of repository IDs from AppConfig[:composers_repository_ids]",
                  $!)
  end

  def self.dataset
    DB.open do |db|
      ds = db[:digital_object]

      if AppConfig[:composers_repositories] != :all
        ds.filter(:repo_id => AppConfig[:composers_repositories])
      end

      ds
    end
  end

end
