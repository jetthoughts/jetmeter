require 'minitest/autorun'
require 'jetmeter/repository_issues_loader'

class Jetmeter::RepositoryIssuesLoaderTest < Minitest::Test
  def test_calls_configed_client_for_all_repository_issues
    mocked_client = Minitest::Mock.new
    config = OpenStruct.new(
      client: mocked_client,
      repository_name: 'marchi-martius/jetmeter'
    )
    mocked_client.expect :list_issues, [{}], ['marchi-martius/jetmeter', { state: 'all' }]

    events = Jetmeter::RepositoryIssuesLoader.new(config).load

    mocked_client.verify
  end
end
