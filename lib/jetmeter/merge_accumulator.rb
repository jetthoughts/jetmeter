module Jetmeter
  class MergeAccumulator
    MERGED_EVENT = 'merged'.freeze

    def valid?(event, flow)
      event.issue_event? &&
        event.event == MERGED_EVENT &&
        merging_transition?(flow)
    end

    def additive
      true
    end

    private

    def merging_transition?(flow)
      flow.transitions(additive).any? do |from, to|
        from.nil? && to.include?(:merged)
      end
    end
  end
end
