module Jetmeter
  class ResourceAdapter < SimpleDelegator
    def issue?
      false
    end

    def issue_event?
      false
    end

    def flow_date
      raise NotImplementedError
    end

    def issue_number
      raise NotImplementedError
    end
  end
end
