module Jetmeter
  class FlowReducer
    attr_reader :flows

    def initialize(events_loader)
      @events = events_loader.load
      @flows = {}
    end

    def reduce(flow, accumulator)
      @flows[flow] = Hash.new { |hash, date| hash[date] = [] }

      @events.select(&accumulator.selector(flow)).each do |event|
        if accumulator.additive
          @flows[flow][event.created_at.to_date].push(event)
        else
          @flows[flow][event.created_at.to_date].delete(event)
        end
      end

      self
    end

    def reduce_all(flows, accumulators)
      flows.each { |flow| accumulators.each { |accum| reduce(flow, accum) } }
      self
    end
  end
end
