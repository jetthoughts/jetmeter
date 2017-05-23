require 'minitest/autorun'
require 'jetmeter/open_accumulator'

require_relative '../helpers/test_flow'

class TestIssue < SimpleDelegator
  def issue?
    true
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
      pull_request: {},
      state: 'open'
    )

    assert(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_approves_open_issues
    issue = TestIssue.new(
      number: 1347,
      state: 'open'
    )

    assert(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_approves_closed_pull_requests
    issue = TestIssue.new(
      number: 1347,
      state: 'closed',
      pull_request: {}
    )

    assert(build_accumulator.valid?(issue, build_flow))
  end

  def test_valid_declines_closed_issue_without_pull_request
    issue = TestIssue.new(
      number: 1347,
      state: 'closed'
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
