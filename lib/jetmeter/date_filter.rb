module Jetmeter
  class DateFilter
    def apply?(event, flow)
      flow.filters.key?(:start_at) && event.created_at < flow.filters[:start_at]
    end
  end
end
