module Jetmeter
  class FlowReducer
    attr_reader :flows

    def initialize(events_loader)
      @events = events_loader.load
      @flows = {}
    end

    def reduce(accomulator)
      @flows[accomulator.flow] = Hash.new { |flow, date| flow[date] = [] }

      @events.select(&accomulator.selector).each do |event|
        if accomulator.additive?
          @flows[accomulator.flow][event.created_at.to_date].push(event)
        else
          @flows[accomulator.flow][event.created_at.to_date].delete(event)
        end
      end

      self
    end
  end
end
