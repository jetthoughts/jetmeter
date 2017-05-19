module Jetmeter
  class OpenFilter
    def apply?(resource, flow)
      resource.issue? && flow.filters.key?(:open_at) && closed_at?(resource, flow)
    end

    private

    def closed_at?(resource, flow)
      resource.closed_at && resource.closed_at < flow.filters[:open_at]
    end
  end
end

