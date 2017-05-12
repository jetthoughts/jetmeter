module Jetmeter
  class Config
    attr_writer :github_credentials
    attr_accessor :repository_name

    def initialize(api: Octokit::Client)
      raise ArgumentError unless block_given?

      @api = api
      yield self
    end

    def client
      @_client ||= begin
        client = @api.new(@github_credentials)
        client.auto_paginate = true
        client
      end
    end
  end
end
