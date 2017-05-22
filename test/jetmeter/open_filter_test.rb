require 'minitest/autorun'
require 'jetmeter/open_filter'
require 'date'

class Jetmeter::OpenFilterTest < Minitest::Test
  def build_flow(open_at: nil)
    flow = OpenStruct.new(filters: {})
    flow.filters[:open_at] = open_at if open_at
    flow
  end

  def build_filter(issues: [])
    Jetmeter::OpenFilter.new(issues)
  end

  def test_apply_to_issue_closed_before_configured_open_date
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    issue = OpenStruct.new(
      issue?: true,
      closed_at: DateTime.iso8601('2017-05-10T13:22')
    )

    assert(build_filter.apply?(issue, flow))
  end

  def test_does_not_apply_to_open_issue
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    issue = OpenStruct.new(
      issue?: true,
      closed_at: nil
    )

    refute(build_filter.apply?(issue, flow))
  end

  def test_does_not_apply_to_issue_closed_after_configured_date
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    issue = OpenStruct.new(
      issue?: true,
      closed_at: DateTime.iso8601('2017-05-11T22:22')
    )

    refute(build_filter.apply?(issue, flow))
  end

  def test_does_not_apply_for_non_configured_flow
    flow = build_flow
    issue = OpenStruct.new(
      issue?: true,
      closed_at: DateTime.iso8601('2017-05-11T22:22')
    )

    refute(build_filter.apply?(issue, flow))
  end

  def test_apply_to_event_for_issue_closed_before_configured_open_date
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    filter = build_filter(
      issues: [
        OpenStruct.new(number: 1, closed_at: DateTime.iso8601('2017-05-10T13:22'))
      ]
    )
    issue = OpenStruct.new(
      issue_event?: true,
      issue_number: 1
    )

    assert(filter.apply?(issue, flow))
  end

  def test_does_not_apply_to_event_for_issue_closed_after_configured_date
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    filter = build_filter(
      issues: [
        OpenStruct.new(number: 1, closed_at: DateTime.iso8601('2017-05-11T13:22'))
      ]
    )
    issue = OpenStruct.new(
      issue_event?: true,
      issue_number: 1
    )

    refute(filter.apply?(issue, flow))
  end

  def test_does_not_apply_to_event_for_open_issue
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    filter = build_filter(
      issues: [
        OpenStruct.new(number: 1)
      ]
    )
    issue = OpenStruct.new(
      issue_event?: true,
      issue_number: 1
    )

    refute(filter.apply?(issue, flow))
  end

  def test_does_not_apply_to_unknown_event
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    filter = build_filter(
      issues: [
        OpenStruct.new(number: 1)
      ]
    )
    issue = OpenStruct.new(
      issue_event?: true,
      issue_number: 2
    )

    refute(filter.apply?(issue, flow))
  end

  def test_does_not_apply_to_event_for_unconfigured_flow
    filter = build_filter(
      issues: [
        OpenStruct.new(number: 1, closed_at: DateTime.iso8601('2017-05-10T13:22'))
      ]
    )
    issue = OpenStruct.new(
      issue_event?: true,
      issue_number: 1
    )

    refute(filter.apply?(issue, build_flow))
  end

  def test_does_not_apply_to_other_resources
    flow = build_flow(open_at: Date.new(2017, 5, 11))
    resource = OpenStruct.new(
      issue_event?: false,
      issue?: false,
      payload: {}
    )

    refute(build_filter.apply?(resource, flow))
  end
end
