module Jetmeter
  class CLI
    CREDENTIAL_PATH = File.expand_path('~/.jetmeter/token').freeze
    CACHE_PATH = File.expand_path('~/.jetmeter/cache').freeze

    def initialize(config_path)
      @config = eval(File.read(config_path))
      prepare_cache
      authenticate_user
    end

    def run
      puts "Receiving issue events..."
      repository_issue_events = Jetmeter::Collection.new(
        Jetmeter::RepositoryIssueEventsLoader.new(@config).load,
        Jetmeter::IssueEventAdapter
      )

      puts "Receiving issues..."
      repository_issues = Jetmeter::Collection.new(
        Jetmeter::RepositoryIssuesLoader.new(@config).load,
        Jetmeter::IssueAdapter
      )

      accums = [
        Jetmeter::OpenAccumulator.new,
        Jetmeter::LabelAccumulator.new,
        Jetmeter::LabelAccumulator.new(additive: false),
        Jetmeter::CloseAccumulator.new,
        Jetmeter::CloseAccumulator.new(additive: false),
        Jetmeter::MergeAccumulator.new
      ]
      filters = [
        Jetmeter::DateFilter.new,
        Jetmeter::OpenFilter.new(repository_issues)
      ]

      reducer = Jetmeter::FlowReducer.new(
        [repository_issues, repository_issue_events],
        @config
      )

      puts "Analyzing received data..."
      reducer.reduce(accums, filters)

      puts "Initializing CSV formatter..."
      formatter = Jetmeter::CsvFormatter.new(@config, reducer)

      puts "Saving CSV file..."
      File.open(@config.output_path, 'wb') do |file|
        formatter.save(file)
        puts "Created CSV: #{@config.output_path}"
      end
    end

    private

    def authenticate_user
      if access_token_stored? && access_token_readable?
        @config.github_credentials = { access_token: File.read(CREDENTIAL_PATH) }
      else
        login, password = ask_credentials
        @config.github_credentials = { login: login, password: password }

        authorization = create_authorization
        save_access_token(authorization.token)
      end
    end

    def prepare_cache
      FileUtils.mkdir_p CACHE_PATH
      @config.cache_path = CACHE_PATH
    end

    def ask_credentials
      puts "Your github login:"
      login = STDIN.gets.chomp

      puts "Your github password:"
      password = STDIN.noecho(&:gets).chomp

      [login, password]
    end

    def ask_two_factor
      puts 'Enter 2-factor authentication token:'
      STDIN.gets.chomp
    end

    def create_authorization
      auth_note = "jetmeter for #{ENV['USER']}@#{ENV['HOSTNAME']}"
      @config.client.create_authorization(
        scopes: [:repo],
        note: auth_note
      )
    rescue Octokit::OneTimePasswordRequired
      @config.client.create_authorization(
        scopes: [:repo],
        note: auth_note,
        headers: { 'X-GitHub-OTP' => ask_two_factor }
      )
    end

    def save_access_token(token)
      File.write(CREDENTIAL_PATH, token)
      @config.github_credentials = { access_token: token }
    end

    def access_token_stored?
      File.exist?(CREDENTIAL_PATH)
    end

    def access_token_readable?
      File.readable?(CREDENTIAL_PATH)
    end
  end
end
