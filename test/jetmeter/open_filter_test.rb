require 'minitest/autorun'
require 'jetmeter/open_filter'
require 'date'

class Jetmeter::OpenFilterTest < Minitest::Test
  def build_flow(open_at: nil)
    flow = OpenStruct.new(filters: {})
    flow.filters[:open_at] = open_at if open_at
    flow
  end

  def build_filter
    Jetmeter::OpenFilter.new
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

  def does_not_apply_to_non_issue_resources
    flow = build_flow
    event = OpenStruct.new(
      issue?: false,
      closed_at: DateTime.iso8601('2017-05-11T22:22')
    )

    refute(build_filter.apply?(resource, flow))
  end
end
