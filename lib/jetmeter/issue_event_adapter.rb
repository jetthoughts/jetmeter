require 'jetmeter/resource_adapter'

module Jetmeter
  class IssueEventAdapter < ResourceAdapter
    def issue_event?
      true
    end

    def flow_date
      created_at.to_date
    end

    def issue_number
      issue[:number]
    end
  end
end
