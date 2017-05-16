require 'minitest/autorun'
require 'jetmeter/merge_accumulator'

require_relative 'test_flow'

class Jetmeter::MergeAccumulatorTest < Minitest::Test
  def build_accumulator(name: 'Closed', merging: true)
    flow = TestFlow.new(additions: { nil => merging ? [:merged] : [] })
    config = OpenStruct.new(flows: { name => flow })
    Jetmeter::MergeAccumulator.new(config)
  end

  def test_selector_returns_closure
    accumulator = build_accumulator

    assert_kind_of(Proc, accumulator.selector('Closed'))
  end

  def test_selector_approves_merged_event_for_merging_flow
    accumulator = build_accumulator
    event = OpenStruct.new(
      event: 'merged',
      issue: { number: 1 }
    )

    assert(accumulator.selector('Closed').call(event))
  end

  def test_selector_declies_merged_event_for_regular_flow
    accumulator = build_accumulator(name: 'WIP', merging: false)
    event = OpenStruct.new(
      event: 'merged',
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
