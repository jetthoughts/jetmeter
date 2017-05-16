module Jetmeter
  class OpenAccumulator
    ISSUES_EVENT_TYPE = 'IssuesEvent'.freeze
    OPENED_ACTION = 'opened'.freeze

    def initialize(config)
      @flows = config.flows
    end

    def selector(flow_name)
      lambda do |event|
        event.type == ISSUES_EVENT_TYPE &&
          event.payload[:action] == OPENED_ACTION &&
          @flows[flow_name]&.opening?
      end
    end

    def additive
      true
    end
  end
end
