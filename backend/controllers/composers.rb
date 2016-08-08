class ArchivesSpaceService < Sinatra::Base

  RESOURCE_IDENTIFIER_SEPARATOR = '.'

  Endpoint.get('/plugins/composers/summary')
    .description("Get summarized Digital Object data for a specific Resource")
    .params(["resource_identifier", String],
            ["separated_by", String, "Identifier parts separated by this value", :optional => true])
    .permissions([])
    .returns([200, "[(:digital_object)]"]) \
  do
    separated_by = params[:separated_by] || RESOURCE_IDENTIFIER_SEPARATOR
    json_response(ComposersSummary.new(params[:resource_identifier], separated_by))
  end


  Endpoint.get('/plugins/composers/digital_objects')
    .description("Get Digital Object data for a Resource or Archival Object specified by a Component ID")
    .params(["component_id", String])
    .permissions([])
    .returns([200, "[(:digital_object)]"]) \
  do
    raise NotImplementedError.new
  end


  Endpoint.get('/plugins/composers/detailed')
    .description("Get detailed Digital Object data for a specific Resource")
    .params(["resource_identifier", String],
            ["separated_by", String, "Identifier parts separated by this value", :optional => true])
    .permissions([])
    .returns([200, "[(:digital_object)]"]) \
  do
    separated_by = params[:separated_by] || RESOURCE_IDENTIFIER_SEPARATOR
    json_response(ComposersDetailed.new(params[:resource_identifier], separated_by))
  end

end
