module Jetmeter
  class  RepositoryIssuesLoader
    def initialize(config)
      @repository_name = config.repository_name
      @client = config.client
    end

    def load
      return @issues if defined?(@issues)
      @issues = @client.list_issues(@repository_name, state: 'all')
    end
  end
end
