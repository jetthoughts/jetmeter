require 'minitest/autorun'
require 'jetmeter/close_accumulator'

require_relative '../helpers/test_flow'

class Jetmeter::CloseAccumulatorTest < Minitest::Test
  def build_flow(closing: true)
    TestFlow.new(additions: { nil => closing ? [:closed] : [] })
  end

  def test_valid_approves_closed_event_for_closing_flow
    accumulator = Jetmeter::CloseAccumulator.new
    event = OpenStruct.new(
      issue_event?: true,
      event: 'closed',
      issue: { number: 1 }
    )

    assert(accumulator.valid?(event, build_flow))
  end

  def test_valid_declies_close_event_for_regular_flow
    accumulator = Jetmeter::CloseAccumulator.new
    event = OpenStruct.new(
      issue_event?: true,
      event: 'closed',
      issue: { number: 1 }
    )

    refute(accumulator.valid?(event, build_flow(closing: false)))
  end

  def test_valid_declines_other_event
    accumulator = Jetmeter::CloseAccumulator.new
    event = OpenStruct.new(
      issue_event?: true,
      event: 'labeled',
      issue: { number: 1 }
    )

    refute(accumulator.valid?(event, build_flow))
  end

  def test_valid_ignores_non_issue_events
    accumulator = Jetmeter::CloseAccumulator.new
    event = OpenStruct.new(
      issue_event?: false,
      event: 'closed',
      issue: { number: 1 }
    )

    refute(accumulator.valid?(event, build_flow))
  end
end
