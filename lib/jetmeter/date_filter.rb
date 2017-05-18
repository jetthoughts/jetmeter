module Jetmeter
  class DateFilter
    def apply?(resource, flow)
      flow.filters.key?(:start_at) && resource.created_at < flow.filters[:start_at]
    end
  end
end
