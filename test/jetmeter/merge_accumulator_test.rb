require 'minitest/autorun'
require 'jetmeter/merge_accumulator'

require_relative '../helpers/test_flow'

class Jetmeter::MergeAccumulatorTest < Minitest::Test
  def build_flow(name: 'Closed', merging: true)
    TestFlow.new(additions: { nil => merging ? [:merged] : [] })
  end

  def build_accumulator
    Jetmeter::MergeAccumulator.new
  end

  def test_valid_approves_merged_event_for_merging_flow
    event = OpenStruct.new(
      issue_event?: true,
      event: 'merged',
      issue: { number: 1 }
    )

    assert(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declies_merged_event_for_regular_flow
    flow = build_flow(name: 'WIP', merging: false)
    event = OpenStruct.new(
      issue_event?: true,
      event: 'merged',
      issue: { number: 1 }
    )

    refute(build_accumulator.valid?(event, flow))
  end

  def test_valid_declines_other_event
    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 }
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declines_non_issue_events
    event = OpenStruct.new(
      issue_event?: false,
      event: 'merged',
      issue: { number: 1 }
    )

    refute(build_accumulator.valid?(event, build_flow))
  end
end
