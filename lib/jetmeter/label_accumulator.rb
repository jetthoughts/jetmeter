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
        @flows.key?(flow_name) &&
          labeling_transition?(@flows[flow_name], event) ||
          unlabeling_transition?(@flows[flow_name], event)
      end
    end

    private

    def labeling_transition?(flow, event)
      if event.event == LABELED_EVENT
        flow.transitions(additive).any? do |from, to|
          to.include?(event.label[:name]) && from.nil? || corresponding_event?(event, from)
        end
      end
    end

    def unlabeling_transition?(flow, event)
      if event.event == UNLABELED_EVENT
        flow.transitions(additive).any? do |from, to|
          to.nil? && event.label[:name] == from
        end
      end
    end

    def corresponding_events
      @_corresponding_events ||= @events_loader.load.select do |e|
        e.event == UNLABELED_EVENT
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
