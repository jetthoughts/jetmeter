module Jetmeter
  class CloseAccumulator
    CLOSED_EVENT = 'closed'.freeze

    attr_reader :additive

    def initialize(additive: true)
      @additive = additive
    end

    def valid?(event, flow)
      event.event == CLOSED_EVENT && closing_transition?(flow)
    end

    private

    def closing_transition?(flow)
      flow.transitions(additive).any? do |from, to|
        from.nil? && to.include?(:closed)
      end
    end
  end
end
