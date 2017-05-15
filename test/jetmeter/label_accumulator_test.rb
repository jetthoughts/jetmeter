require 'minitest/autorun'
require 'jetmeter/label_accumulator'

require_relative 'test_events_loader'

class Jetmeter::LabelAccumulatorTest < Minitest::Test
  def build_accumulator(name: 'Backlog', from: nil, to: 'Backlog', additive: true)
    events_loader = TestEventsLoader.new
    flow          = OpenStruct.new(additions: { from => [to] })
    config        = OpenStruct.new(flows: { name => flow })

    Jetmeter::LabelAccumulator.new(events_loader, config, additive: additive)
  end

  def test_selector_returns_closure
    accumulator = build_accumulator

    assert_kind_of(Proc, accumulator.selector('Backlog'))
  end

  def test_selector_approves_backlog_event
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Backlog' }
    )

    assert(accumulator.selector('Backlog').call(event))
  end

  def test_selector_declines_other_labeled_event
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Other' }
    )

    refute(accumulator.selector('Backlog').call(event))
  end

  def test_selector_approves_dev_ready_event_with_corresponing_backlog
    accumulator = build_accumulator(from: 'Backlog', to: 'Dev - Ready')
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:22:10') # after 10 seconds after Backlog unlabeled
    )

    assert(accumulator.selector('Backlog').call(event))
  end

  def test_selector_declines_event_without_correspondiong_unlabeled_event
    accumulator = build_accumulator(from: 'Backlog', to: 'Dev - Ready')
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 3 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:22')
    )

    refute(accumulator.selector('Backlog').call(event))
  end

  def test_selector_declines_event_with_corresponding_event_more_then_minute_ago
    accumulator = build_accumulator(from: 'Backlog', to: 'Dev - Ready')
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(accumulator.selector('Backlog').call(event))
  end

  def test_selector_declines_unlabeled_events
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'unlabeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(accumulator.selector('Backlog').call(event))
  end

  def test_selector_declines_closed_events
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'closed',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-11T11:24')
    )

    refute(accumulator.selector('Backlog').call(event))
  end

  def test_non_additive_selector_approves_substriction_transitions
    events_loader = TestEventsLoader.new
    flow          = OpenStruct.new(substractions: { 'Dev - Working' => ['Dev - Ready'] })
    config        = OpenStruct.new(flows: { 'Dev - Working' => flow })
    accumulator   = Jetmeter::LabelAccumulator.new(events_loader, config, additive: false)

    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 },
      label: { name: 'Dev - Ready' },
      created_at: DateTime.iso8601('2017-05-13T11:30:30') # 30 seconds after unlabeled Dev - Working
    )

    refute(accumulator.additive)
    assert(accumulator.selector('Dev - Working').call(event))
  end
end
