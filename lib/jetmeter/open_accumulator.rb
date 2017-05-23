module Jetmeter
  class OpenAccumulator
    OPEN_STATE = 'open'.freeze

    def valid?(resource, flow)
      resource.issue? &&
        opening_transition?(flow) &&
        open_or_worked?(resource)
    end

    def additive
      true
    end

    private

    def opening_transition?(flow)
      flow.transitions(additive).any? do |from, to|
        from.nil? && to.include?(:opened)
      end
    end

    def open_or_worked?(issue)
      issue[:state] == OPEN_STATE || issue.key?(:pull_request)
    end
  end
end
