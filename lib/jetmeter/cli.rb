module Jetmeter
  class CLI
    CREDENTIAL_PATH = File.expand('~/.jetmeter')

    def initialize(config_path)
      @config = eval(File.read(config_path))
      @config.github_credentials = credentials
      save_access_token unless access_token_stored?
    end

    def run
      events_loader = Jetemeter::RepositoryIssueEventsLoader.new(@config)

      reducer = Jetmeter::FlowReducer.new(events_loader)
      accumulators = [
        Jetmeter::LabelAccumulator.new(events_loader, @config),
        Jetmeter::LabelAccumulator.new(events_loader, @config, additive: false),
        Jetmeter::CloseAccumulator.new(@config)
      ]

      reducer = reducer.reduce_all(@config.flows.keys, accumulators)
      File.open(@config.output_path, 'wb') do |file|
        Jetmeter::CsvFormatter.new(reducer.flows).save(file)
      end
    end

    private

    def credentials
      if access_token_stored? && access_token_readable?
        { access_token: File.read(CREDENTIAL_PATH) }
      else
        username, password = ask_credentials
        { usename: username, password: password }
      end
    end

    def ask_credentials
      puts "Your github username:"
      username = gets
      puts "Your github password:"
      password = STDIN.noecho(&:gets)

      [username, password]
    end

    def save_access_token
      if access_token_writable?
        auth_note = "jetmeter for #{ENV['USER']}@#{ENV['HOSTNAME']}}"
        authorization = @config.client.create_authorization(
          scopes: [:repo],
          note: auth_note
        )
        File.write(CREDENTIAL_PATH, authorization.hashed_token)
      end
    end

    def access_token_stored?
      File.exist?(CREDENTIAL_PATH)
    end

    def access_token_readable?
      File.readable?(CREDENTIAL_PATH)
    end

    def access_token_writable?
      File.writable?(CREDENTIAL_PATH)
    end
  end
end
