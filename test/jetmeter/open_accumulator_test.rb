require 'minitest/autorun'
require 'jetmeter/open_accumulator'

class Jetmeter::OpenAccumulatorTest < Minitest::Test
  def build_accumulator(name: 'Backlog', opening: true)
    config = OpenStruct.new(flows: { name => OpenStruct.new(opening?: opening) })
    Jetmeter::OpenAccumulator.new(config)
  end

  def test_selector_returns_closure
    accumulator = build_accumulator

    assert_kind_of(Proc, accumulator.selector('Backlog'))
  end

  def test_selector_approves_opened_event_for_opening_flow
    accumulator = build_accumulator
    event = OpenStruct.new(
      type: 'IssuesEvent',
      payload: {
        action: 'opened',
        issue: { number: 1 }
      }
    )

    assert(accumulator.selector('Backlog').call(event))
  end

  def test_selector_declines_opened_event_for_regular_flow
    accumulator = build_accumulator(name: 'WIP', opening: false)
    event = OpenStruct.new(
      type: 'IssuesEvent',
      payload: {
        action: 'opened',
        issue: { number: 1 }
      }
    )

    refute(accumulator.selector('WIP').call(event))
  end

  def test_selector_declines_other_event
    accumulator = build_accumulator
    event = OpenStruct.new(
      type: 'IssuesEvent',
      payload: {
        action: 'edited',
        issue: { number: 1 }
      }
    )

    refute(accumulator.selector('Backlog').call(event))
  end

  def test_additive_always_true
    accumulator = build_accumulator
    assert(accumulator.additive)
  end
end
