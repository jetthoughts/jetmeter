require 'minitest/autorun'
require 'jetmeter/label_accumulator'
require 'date'

require_relative '../helpers/test_flow'

class Jetmeter::LabelAccumulatorTest < Minitest::Test
  def build_flow(from: nil, to: 'Backlog')
    TestFlow.new(additions: { from => [to] })
  end

  def build_accumulator(additive: true)
    Jetmeter::LabelAccumulator.new(additive: additive)
  end

  def test_valid_approves_backlog_event
    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Backlog' }
    )

    assert(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declines_other_labeled_event
    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Other' }
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_approves_dev_ready_event_with_corresponing_backlog
    flow = build_flow(from: 'Backlog', to: 'Dev - Ready')
    accumulator = build_accumulator

    event = OpenStruct.new(
      issue_event?: true,
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Backlog' },
      created_at: DateTime.iso8601('2017-05-11T11:22')
    )
    refute(accumulator.valid?(event, flow))

    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:22:10')
    )

    assert(accumulator.valid?(event, flow))
  end

  def test_valid_approves_dev_ready_event_with_corresponing_backlog_in_reverse_order
    flow = build_flow(from: 'Backlog', to: 'Dev - Ready')
    accumulator = build_accumulator

    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:22:00')
    )
    refute(accumulator.valid?(event, flow))

    event = OpenStruct.new(
      issue_event?: true,
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Backlog' },
      created_at: DateTime.iso8601('2017-05-11T11:22:30')
    )

    assert(accumulator.valid?(event, flow))
  end

  def test_valid_approves_unlabeling_flow
    flow = build_flow(from: 'Backlog', to: nil)
    accumulator = build_accumulator

    event = OpenStruct.new(
      issue_event?: true,
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Backlog' },
      created_at: DateTime.iso8601('2017-05-11T11:22:10')
    )

    assert(accumulator.valid?(event, flow))
  end

  def test_valid_declines_event_without_correspondiong_unlabeled_event
    flow = build_flow(from: 'Backlog', to: 'Dev - Ready')
    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 3 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:22')
    )

    refute(build_accumulator.valid?(event, flow))
  end

  def test_valid_declines_event_with_corresponding_event_more_then_minute_ago
    flow = build_flow(from: 'Backlog', to: 'Dev - Ready')
    accumulator = build_accumulator

    event = OpenStruct.new(
      issue_event?: true,
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Backlog' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )
    accumulator.valid?(event, flow)

    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:25:15')
    )

    refute(accumulator.valid?(event, flow))
  end

  def test_valid_declines_unlabeled_events
    event = OpenStruct.new(
      issue_event?: true,
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declines_closed_events
    event = OpenStruct.new(
      issue_event?: true,
      event: 'closed',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_non_additive_valid_approves_substriction_transitions
    flow = TestFlow.new(
      substractions: { 'Dev - Working' => ['Dev - Ready'] }
    )
    accumulator = build_accumulator(additive: false)

    event = OpenStruct.new(
      issue_event?: true,
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Dev - Working' },
      created_at: DateTime.iso8601('2017-05-13T11:30')
    )
    accumulator.valid?(event, flow)

    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-13T11:30:30')
    )
    assert(accumulator.valid?(event, flow))
  end

  def test_valid_declines_non_issue_events
    event = OpenStruct.new(
      issue_event?: false,
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Backlog' }
    )

    refute(build_accumulator.valid?(event, build_flow))
  end
end
