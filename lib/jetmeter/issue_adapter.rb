require 'jetmeter/resource_adapter'

module Jetmeter
  class IssueAdapter < ResourceAdapter
    def issue?
      true
    end

    def flow_date
      created_at.to_date
    end

    def issue_number
      number
    end
  end
end
