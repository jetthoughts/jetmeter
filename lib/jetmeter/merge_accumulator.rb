module Jetmeter
  class MergeAccumulator
    MERGED_EVENT = 'merged'.freeze

    def initialize(config)
      @flows = config.flows
    end

    def selector(flow_name)
      lambda do |event|
        event.event == MERGED_EVENT && merging_transition?(@flows[flow_name])
      end
    end

    def additive
      true
    end

    private

    def merging_transition?(flow)
      if flow
        flow.transitions(additive).any? do |from, to|
          from.nil? && to.include?(:merged)
        end
      end
    end
  end
end
