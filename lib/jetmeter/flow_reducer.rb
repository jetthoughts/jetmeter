module Jetmeter
  class FlowReducer
    attr_reader :flows

    def initialize(events_loader, config)
      @events = events_loader.load
      @config = config
      @flows = Hash.new do |hash, flow_name|
        hash[flow_name] = Hash.new { |flow, date| flow[date] = [] }
      end
    end

    def reduce(accumulators, filters)
      @events.each do |event|
        reduce_event(event, accumulators, filters)
      end
    end

    def merge(other)
      @flows.merge!(other.flows) do |flow_name, our_dates, their_dates|
        our_dates.merge(their_dates) do |date, our_events, their_events|
          our_events + their_events
        end
      end
    end

    private

    def reduce_event(event, accumulators, filters)
      @config.flows.each_pair do |flow_name, flow_config|
        next if filters.any? { |filter| filter.apply?(event, flow_config) }

        accumulators.each do |accumulator|
          if accumulator.valid?(event, flow_config)
            apply_accumulator(event, accumulator, flow_name)
          end
        end
      end
    end

    def apply_accumulator(event, accumulator, flow_name)
      if accumulator.additive
        @flows[flow_name][event.created_at.to_date].push(issue_number(event))
      else
        @flows[flow_name][event.created_at.to_date].delete(issue_number(event))
      end
    end

    def issue_number(event)
      event.payload ? event.payload.issue[:number] : event.issue[:number]
    end
  end
end
