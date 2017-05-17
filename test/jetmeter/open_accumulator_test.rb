require 'minitest/autorun'
require 'jetmeter/open_accumulator'

require_relative 'test_flow'

class Jetmeter::OpenAccumulatorTest < Minitest::Test
  def build_flow(name: 'Backlog', opening: true)
    TestFlow.new(additions: { nil => opening ? [:opened] : [] })
  end

  def build_accumulator
    Jetmeter::OpenAccumulator.new
  end

  def test_valid_approves_opened_event_for_opening_flow
    event = OpenStruct.new(
      type: 'IssuesEvent',
      payload: {
        action: 'opened',
        issue: { number: 1 }
      }
    )

    assert(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declines_opened_event_for_regular_flow
    flow = build_flow(name: 'WIP', opening: false)
    event = OpenStruct.new(
      type: 'IssuesEvent',
      payload: {
        action: 'opened',
        issue: { number: 1 }
      }
    )

    refute(build_accumulator.valid?(event, flow))
  end

  def test_valid_declines_other_event
    event = OpenStruct.new(
      type: 'IssuesEvent',
      payload: {
        action: 'edited',
        issue: { number: 1 }
      }
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_additive_always_true
    accumulator = build_accumulator
    assert(accumulator.additive)
  end
end
