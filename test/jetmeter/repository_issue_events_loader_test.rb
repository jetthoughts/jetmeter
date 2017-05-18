require 'minitest/autorun'
require 'jetmeter/repository_issue_events_loader'

class Jetmeter::RepositoryIssueEventsLoaderTest < Minitest::Test
  def test_calls_configed_client_for_repository_issue_events
    mocked_client = Minitest::Mock.new
    config = OpenStruct.new(
      client: mocked_client,
      repository_name: 'marchi-martius/jetmeter'
    )
    mocked_client.expect :repository_issue_events, [{}], ['marchi-martius/jetmeter']

    Jetmeter::RepositoryIssueEventsLoader.new(config).load

    mocked_client.verify
  end
end
