module Jetmeter
  class OpenAccumulator
    def valid?(resource, flow)
      resource.issue? &&
        opening_transition?(flow) &&
        open_or_finished?(resource)
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

    def open_or_finished?(issue)
      issue[:closed_at].nil? || issue.key?(:pull_request)
    end
  end
end
