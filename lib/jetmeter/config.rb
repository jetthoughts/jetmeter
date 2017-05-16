module Jetmeter
  class Config
    attr_accessor :repository_name
    attr_accessor :output_path
    attr_reader :flows

    def initialize(api: Octokit::Client)
      raise ArgumentError unless block_given?

      @api = api
      @flows = {}

      yield self
    end

    def github_credentials=(credentials)
      @github_credentials = credentials
      @_client = nil
    end

    def client
      @_client ||= begin
        client = @api.new(@github_credentials)
        client.auto_paginate = true
        client
      end
    end

    def register_flow(flow_name, &block)
      @flows[flow_name] = Jetmeter::Config::Flow.new.tap(&block)
    end

    def register_closing_flow(flow_name, &block)
      if block_given?
        @flows[flow_name] = Jetmeter::Config::Flow.new(closing: true).tap(&block)
      else
        @flows[flow_name] = Jetmeter::Config::Flow.new(closing: true)
      end
    end
  end
end
