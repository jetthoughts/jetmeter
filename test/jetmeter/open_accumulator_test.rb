require 'minitest/autorun'
require 'jetmeter/open_accumulator'

require_relative '../helpers/test_flow'

class Jetmeter::OpenAccumulatorTest < Minitest::Test
  def build_flow(name: 'Backlog', opening: true)
    TestFlow.new(additions: { nil => opening ? [:opened] : [] })
  end

  def build_accumulator
    Jetmeter::OpenAccumulator.new
  end

  def test_valid_approves_pull_request
    event = OpenStruct.new(
      issue?: true,
      number: 1347,
      pull_request: {}
    )

    assert(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_approves_open_issues
    event = OpenStruct.new(
      issue?: true,
      number: 1347,
      closed_at: nil
    )

    assert(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_approves_closed_pull_requests
    event = OpenStruct.new(
      issue?: true,
      number: 1347,
      closed_at: Time.new(2017, 2, 11),
      pull_request: {}
    )

    assert(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declines_closed_issue_without_pull_request
    event = OpenStruct.new(
      issue?: true,
      number: 1347,
      closed_at: Time.new(2017, 2, 11)
    )

    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declines_non_issues
    event = OpenStruct.new(
      issue?: false
    )
    refute(build_accumulator.valid?(event, build_flow))
  end

  def test_valid_declines_issue_for_non_opened_flows
    event = OpenStruct.new(
      issue?: true,
      number: 1347,
      pull_request: {}
    )
    flow = build_flow(opening: false)

    refute(build_accumulator.valid?(event, flow))
  end

  def test_additive_always_true
    accumulator = build_accumulator
    assert(accumulator.additive)
  end
end
