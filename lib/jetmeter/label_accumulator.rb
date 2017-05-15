module Jetmeter
  class LabelAccumulator
    LABELED_EVENT = 'labeled'.freeze
    UNLABELED_EVENT = 'unlabeled'.freeze
    MAX_LABEL_CHANGE_TIME = 60.freeze

    attr_reader :additive

    def initialize(events_loader, config, additive: true)
      @events_loader = events_loader
      @flows = config.flows
      @additive = additive
    end

    def selector(flow_name)
      lambda do |event|
        break false if event.event != event_name
        break false unless flow = @flows[flow_name]

        transitions(flow).any? do |from, to|
          Array(to).include?(event.label[:name]) && from.nil? || corresponding_event?(event, from)
        end
      end
    end

    private

    def event_name
      LABELED_EVENT
    end

    def corresponding_event_name
      UNLABELED_EVENT
    end

    def transitions(flow)
      additive ? flow.additions : flow.substractions
    end

    def corresponding_events
      @_corresponding_events ||= @events_loader.load.select do |e|
        e.event == corresponding_event_name
      end
    end

    def corresponding_event?(event, from)
      corresponding_events.any? do |corresponding|
        corresponding.label[:name] == from &&
          corresponding.issue[:number] == event.issue[:number] &&
          (corresponding.created_at.to_time - event.created_at.to_time).abs < MAX_LABEL_CHANGE_TIME
      end
    end
  end
end
