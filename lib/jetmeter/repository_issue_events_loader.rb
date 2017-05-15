module Jetmeter
  class RepositoryIssueEventsLoader
    def initialize(config)
      @repository_name = config.repository_name
      @client = config.client
    end

    def load
      return @events if defined?(@events)
      @events = @client.repository_issue_events(@repository_name)
    end
  end
end
