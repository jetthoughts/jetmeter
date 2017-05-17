module Jetmeter
  class LabelAccumulator
    LABELED_EVENT = 'labeled'.freeze
    UNLABELED_EVENT = 'unlabeled'.freeze
    CORRESPONDING_EVENTS_LIMIT = 15
    MAX_LABEL_CHANGE_TIME = 60

    attr_reader :additive

    def initialize(additive: true)
      @corresponding_events = { LABELED_EVENT => [], UNLABELED_EVENT => [] }
      @additive = additive
    end

    def valid?(event, flow)
      store_corresponding_event(event)

      labeling_transition?(flow, event) || unlabeling_transition?(flow, event)
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
          from == event.label[:name] && to.any? { |label| label.nil? || corresponding_event?(event, label) }
        end
      end
    end

    def store_corresponding_event(event)
      return unless [LABELED_EVENT, UNLABELED_EVENT].include?(event.event)

      @corresponding_events[event.event].push(event)
      if @corresponding_events[event.event].length > CORRESPONDING_EVENTS_LIMIT
        @corresponding_events[event.event].shift
      end
    end

    def corresponding_event?(event, label)
      corresponding_type = event.event == LABELED_EVENT ? UNLABELED_EVENT : LABELED_EVENT

      @corresponding_events[corresponding_type].any? do |corresponding|
        corresponding.label[:name] == label &&
          corresponding.issue[:number] == event.issue[:number] &&
          (corresponding.created_at.to_time - event.created_at.to_time).abs < MAX_LABEL_CHANGE_TIME
      end
    end
  end
end
