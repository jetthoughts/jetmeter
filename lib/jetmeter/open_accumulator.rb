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
          opening_transition?(@flows[flow_name])
      end
    end

    def additive
      true
    end

    private

    def opening_transition?(flow)
      if flow
        flow.transitions(additive).any? do |from, to|
          from.nil? && to.include?(:opened)
        end
      end
    end
  end
end
