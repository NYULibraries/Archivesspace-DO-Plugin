class Composers

  def initialize(resource_ds)
    @resource_ds = resource_ds
  end

  def db
    return @db if @db

    DB.open do |db|
      @db = db
    end

    @db
  end

  def to_json(*args, &block)
    only_the_bits_we_need(dataset).collect {|row| format(row)}.to_json
  end

  protected

  def dataset
    raise NotImplementedError.new
  end

  def format(row)
    raise NotImplementedError.new
  end


  def only_the_bits_we_need(ds)
    ds
  end


  def digital_object_instance_type
    db[:enumeration].join(:enumeration_value, :enumeration_id => :enumeration__id)
      .filter(:enumeration__name => 'instance_instance_type')
      .filter(:enumeration_value__value => 'digital_object')
      .select(:enumeration_value__id)
  end

  def resource_for_identifier(resource_identifier, separated_by)

    identifier_array = resource_identifier.split(separated_by)
    identifier_array.concat((4 - identifier_array.length).times.map { nil })
    identifier_json = JSON(identifier_array)

    db[:resource].filter(:identifier => identifier_json)
  end

  def detailed_url
    return @detailed_url if @detailed_url

    identifier_json = @resource_ds.select(:identifier).first[:identifier]

    separated_by = "--"
    resource_identifer = ASUtils.json_parse(identifier_json).compact.join(separated_by)

    uri = URI.join(AppConfig[:backend_public_proxy_url], "plugins", "composers", "detailed")

    uri.query = "resource_identifier=#{resource_identifer}&separated_by=#{separated_by}"

    @detailed_url = uri.to_s

    @detailed_url
  end
end

class ComposersSummary < Composers

  def initialize(resource_identifier, separated_by = '.')
    resource = resource_for_identifier(resource_identifier, separated_by)

    if resource.count == 0
      raise RecordNotFound.new
    end

    super(resource)
  end

  private

  def dataset
    @resource_ds.join(:archival_object, :root_record_id => :resource__id)
      .join(:instance, :archival_object_id => :archival_object__id)
      .join(:instance_do_link_rlshp, :instance_id => :instance__id)
      .join(:digital_object, :id => :instance_do_link_rlshp__digital_object_id)
      .left_outer_join(:note, :archival_object_id => :archival_object__id)
      .left_outer_join(:extent, :archival_object_id => :archival_object__id)
      .left_outer_join(:date, :archival_object_id => :archival_object__id)
      .filter(:instance__instance_type_id => self.digital_object_instance_type)
      .filter(Sequel.like(:note__notes, "%\"type\"\:\"phystech\"%"))
  end


  def only_the_bits_we_need(ds)
    ds.select(:archival_object__id,
            :archival_object__component_id,
            :archival_object__title,
            :note__notes,
            :extent__container_summary,
            :date__expression)
       .distinct(:archival_object__id)

  end


  def format(row)
    # -  component identifier
    # -  component title
    # -  date expression
    # -  phystech
    # -  extent/phystech
    # -  url to detailed view
    {
      :archival_object_id => row[:id],
      :component_identifier => row[:component_id],
      :component_title => row[:title],
      :date_expression => row[:expression],
      :phystech => row[:notes] ? JSON.parse(row[:notes]) : nil,
      :extent => row[:container_summary],
      :detailed_view => detailed_url
    }
  end
end


class ComposersDetailed < ComposersSummary

  def dataset
    ds = super

    # TODO

    ds
  end


  def only_the_bits_we_need(ds)
    # TODO

    ds
  end


  def format(row)
    # -  resource:
    #    -  identifier
    #    -  title
    #    -  bioghist note
    #    -  scopecontent note
    #  -  archival object:
    #    -  component identifier
    #    -  title
    #    -  date expression
    #    -  phystech
    #    -  extent/phystech
    #    -  scopecontent note
    #    -  accessrestrict note
    #    -  userestrict note
    #    -  rights statements
    #    -  names of linked agents

    # TODO
    row.to_json
  end
end