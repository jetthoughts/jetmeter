module Jetmeter
  class FlowReducer
    attr_reader :flows

    def initialize(events_loader)
      @events = events_loader.load
      @flows = {}
    end

    def reduce(flow, accumulator)
      @flows[flow] ||= Hash.new { |hash, date| hash[date] = [] }

      @events.select(&accumulator.selector(flow)).each do |event|
        issue_number = if event.payload
                         event.payload.issue[:number]
                       else
                         event.issue[:number]
                       end

        if accumulator.additive
          @flows[flow][event.created_at.to_date].push(issue_number)
        else
          @flows[flow][event.created_at.to_date].delete(issue_number)
        end
      end

      self
    end

    def reduce_all(config_flows, accumulators)
      config_flows.each { |flow| accumulators.each { |accum| reduce(flow, accum) } }
      self
    end

    def merge(other)
      @flows = @flows.merge(other.flows) do |flow_name, our_dates, their_dates|
        our_dates.merge(their_dates) do |date, our_events, their_events|
          our_events + their_events
        end
      end
      self
    end
  end
end
