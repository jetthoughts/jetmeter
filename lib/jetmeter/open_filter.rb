module Jetmeter
  class OpenFilter
    def initialize(issues_collection)
      @issues = {}
      issues_collection.each do |issue|
        @issues[issue.number] = issue
      end
    end

    def apply?(resource, flow)
      flow.filters.key?(:open_at) && closed_at?(resource, flow)
    end

    private

    def closed_at?(resource, flow)
      issue = if resource.issue?
                resource
              elsif resource.issue_event?
                @issues[resource.issue_number]
              end
      return false unless issue

      issue.closed_at && issue.closed_at < flow.filters[:open_at]
    end
  end
end

