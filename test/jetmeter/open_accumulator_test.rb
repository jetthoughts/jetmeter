require 'minitest/autorun'
require 'jetmeter/open_accumulator'

require_relative '../helpers/test_flow'

class TestIssue < OpenStruct
  def issue?
    true
  end

  def fields
    Set.new(to_h.keys.map(&:to_sym))
  end
end

class Jetmeter::OpenAccumulatorTest < Minitest::Test
  def build_flow(name: 'Backlog', opening: true)
    TestFlow.new(additions: { nil => opening ? [:opened] : [] })
  end

  def build_accumulator
    Jetmeter::OpenAccumulator.new
  end

  def test_valid_approves_pull_request
    issue = TestIssue.new(
      number: 1347,
      pull_request: {}
    )

    assert(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_approves_open_issues
    issue = TestIssue.new(
      number: 1347,
      closed_at: nil
    )

    assert(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_approves_closed_pull_requests
    issue = TestIssue.new(
      number: 1347,
      closed_at: Time.new(2017, 2, 11),
      pull_request: {}
    )

    assert(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_declines_closed_issue_without_pull_request
    issue = TestIssue.new(
      number: 1347,
      closed_at: Time.new(2017, 2, 11)
    )

    refute(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_declines_non_issues
    issue = OpenStruct.new(
      issue?: false
    )
    refute(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_declines_issue_for_non_opened_flows
    issue = TestIssue.new(
      number: 1347,
      pull_request: {}
    )
    flow = build_flow(opening: false)

    refute(build_accumulator.valid?(issue, flow))
  end

  def test_additive_always_true
    accumulator = build_accumulator
    assert(accumulator.additive)
  end
end
