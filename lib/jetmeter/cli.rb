module Jetmeter
  class CLI
    CREDENTIAL_PATH = File.expand_path('~/.jetmeter')

    def initialize(config_path)
      @config = eval(File.read(config_path))
      authenticate_user
    end

    def run
      repository_issue_events = Jetmeter::RepositoryIssueEventsLoader.new(@config)
      repository_events = Jetmeter::RepositoryEventsLoader.new(@config)

      accums = [
        Jetmeter::LabelAccumulator.new,
        Jetmeter::LabelAccumulator.new(additive: false),
        Jetmeter::CloseAccumulator.new,
        Jetmeter::CloseAccumulator.new(additive: false),
        Jetmeter::MergeAccumulator.new,
        Jetmeter::OpenAccumulator.new
      ]
      filters = [
        Jetmeter::DateFilter.new
      ]

      puts "Fetching events..."
      reducer = Jetmeter::FlowReducer.new(
        [repository_events, repository_issue_events],
        @config
      )

      puts "Reducing events..."
      reducer.reduce(accums, filters)

      puts "Merging events"
      formatter = Jetmeter::CsvFormatter.new(@config, reducer)

      puts "Saving CSV file..."
      File.open(@config.output_path, 'wb') do |file|
        formatter.save(file)
      end

      puts "Created CSV: #{@config.output_path}"
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
