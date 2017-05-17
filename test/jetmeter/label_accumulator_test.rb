require 'minitest/autorun'
require 'jetmeter/label_accumulator'

require_relative 'test_events_loader'
require_relative 'test_flow'

class Jetmeter::LabelAccumulatorTest < Minitest::Test
  def build_flow(from: nil, to: 'Backlog')
    TestFlow.new(additions: { from => [to] })
  end

  def build_accumulator(additive: true)
    events_loader = TestEventsLoader.new
    Jetmeter::LabelAccumulator.new(events_loader, additive: additive)
  end

  def test_selector_approves_backlog_event
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Backlog' }
    )

    assert(build_accumulator.valid?(event, build_flow))
  end

  def test_selector_declines_other_labeled_event
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Other' }
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_selector_approves_dev_ready_event_with_corresponing_backlog
    flow = build_flow(from: 'Backlog', to: 'Dev - Ready')
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:22:10') # after 10 seconds after Backlog unlabeled
    )

    assert(build_accumulator.valid?(event, flow))
  end

  def test_selector_declines_event_without_correspondiong_unlabeled_event
    flow = build_flow(from: 'Backlog', to: 'Dev - Ready')
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 3 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:22')
    )

    refute(build_accumulator.valid?(event, flow))
  end

  def test_selector_declines_event_with_corresponding_event_more_then_minute_ago
    flow = build_flow(from: 'Backlog', to: 'Dev - Ready')
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(build_accumulator.valid?(event, flow))
  end

  def test_selector_declines_unlabeled_events
    event = OpenStruct.new(
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_selector_declines_closed_events
    event = OpenStruct.new(
      event: 'closed',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_non_additive_selector_approves_substriction_transitions
    flow = TestFlow.new(
      substractions: { 'Dev - Working' => ['Dev - Ready'] }
    )

    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-13T11:30:30') # 30 seconds after unlabeled Dev - Working
    )

    assert(build_accumulator(additive: false).valid?(event, flow))
  end
end
