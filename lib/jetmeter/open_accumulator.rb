module Jetmeter
  class OpenAccumulator
    def valid?(event, flow)
      event.issue? && opening_transition?(flow)
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
