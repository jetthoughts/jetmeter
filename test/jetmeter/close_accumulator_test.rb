require 'minitest/autorun'
require 'jetmeter/close_accumulator'

class Jetmeter::CloseAccumulatorTest < Minitest::Test
  def build_accumulator(name: 'Closed', closing: true)
    config = OpenStruct.new(flows: { name => OpenStruct.new(closing?: closing) })
    Jetmeter::CloseAccumulator.new(config)
  end

  def test_selector_returns_closure
    accumulator = build_accumulator

    assert_kind_of(Proc, accumulator.selector('Closed'))
  end

  def test_selector_approves_closed_event_for_closing_flow
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'closed',
      issue: { number: 1 }
    )

    assert(accumulator.selector('Closed').call(event))
  end

  def test_selector_approves_merged_event_for_closing_flow
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'merged',
      issue: { number: 1 }
    )

    assert(accumulator.selector('Closed').call(event))
  end

  def test_selector_declies_close_event_for_regular_flow
    accumulator = build_accumulator(name: 'WIP', closing: false)
    event = OpenStruct.new(
      event: 'closed',
      issue: { number: 1 }
    )

    refute(accumulator.selector('WIP').call(event))
  end

  def test_selector_declines_other_event
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'labeled',
      issue: { number: 1 }
    )

    refute(accumulator.selector('Closed').call(event))
  end
end
