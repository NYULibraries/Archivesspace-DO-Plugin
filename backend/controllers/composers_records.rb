class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/plugins/nyucomposers/composers_records')
    .description("Generate the Composers records for indexing")
    .paginated(true)
    .permissions([:index_system])
    .returns([200, "Composer records"]) \
  do
    ComposersRecords.list(params)
  end

end
