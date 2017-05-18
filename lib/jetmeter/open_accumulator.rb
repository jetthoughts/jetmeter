module Jetmeter
  class OpenAccumulator
    def valid?(resource, flow)
      resource.issue? &&
        opening_transition?(flow) &&
        working?(resource)
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

    def working?(issue)
      !issue.pull_request.nil? || issue[:closed_at].nil?
    end
  end
end
