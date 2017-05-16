require 'minitest/autorun'
require 'jetmeter/repository_events_loader'

class Jetmeter::RepositoryEventsLoaderTest < Minitest::Test
  def test_calls_configured_client_for_repository_events
    mocked_client = Minitest::Mock.new
    config = OpenStruct.new(
      client: mocked_client,
      repository_name: 'marchi-martius/jetmeter'
    )
    mocked_client.expect :repository_events, [], ['marchi-martius/jetmeter']

    Jetmeter::RepositoryEventsLoader.new(config).load

    mocked_client.verify
  end
end
