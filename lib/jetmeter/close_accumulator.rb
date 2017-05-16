module Jetmeter
  class CloseAccumulator
    CLOSED_EVENT = 'closed'.freeze

    attr_reader :additive

    def initialize(config, additive: true)
      @flows = config.flows
      @additive = additive
    end

    def selector(flow_name)
      lambda do |event|
        event.event == CLOSED_EVENT && closing_transition?(@flows[flow_name])
      end
    end

    private

    def closing_transition?(flow)
      if flow
        flow.transitions(additive).any? do |from, to|
          from.nil? && to.include?(:closed)
        end
      end
    end
  end
end
