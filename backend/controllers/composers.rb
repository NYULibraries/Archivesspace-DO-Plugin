class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/plugins/composers/summary')
    .description("Get summarized Digital Object data for a specific Resource")
    .params(["resource_id", String, "A resource identifier like 'FA.AFC.28'"])
    .permissions([])
    .returns([200, "[(:digital_object)]"]) \
  do
    json_response(ComposersLookup.summary(params[:resource_id]))
  end


  Endpoint.get('/plugins/composers/digital_objects')
    .description("Get Digital Object data for a Resource or Archival Object specified by a Component ID")
    .params(["component_id", String])
    .permissions([])
    .returns([200, "[(:digital_object)]"]) \
  do
    json_response(ComposersLookup.digital_objects(params[:component_id]))
  end


  Endpoint.get('/plugins/composers/detailed')
         .description("Get detailed Digital Object data for a specific Resource")
         .params(["resource_id", String])
         .permissions([])
         .returns([200, "[(:digital_object)]"]) \
  do
    json_response(ComposersLookup.detailed(params[:resource_id]))
  end

end
