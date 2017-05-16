module Jetmeter
  class OpenAccumulator
    OPENING_EVENT = 'opened'.freeze

    def initialize(config)
      @flows = config.flows
    end

    def selector(flow_name)
      ->(event) { event.event == OPENING_EVENT && @flows[flow_name]&.opening? }
    end

    def additive
      true
    end
  end
end
