module Jetmeter
  class CloseAccumulator
    CLOSING_EVENTS = [
      CLOSED_EVENT = 'closed'.freeze,
      MERGED_EVENT = 'merged'.freeze
    ]

    def initialize(config)
      @flows = config.flows
    end

    def selector(flow_name)
      ->(event) { CLOSING_EVENTS.include?(event.event) && @flows[flow_name]&.closing? }
    end
  end
end
