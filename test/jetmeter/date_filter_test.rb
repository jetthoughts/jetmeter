require 'minitest/autorun'
require 'jetmeter/date_filter'
require 'date'

class Jetmeter::DateFilterTest < Minitest::Test
  def build_flow(start_at: nil)
    flow = OpenStruct.new(filters: {})
    flow.filters[:start_at] = start_at if start_at
    flow
  end

  def build_filter
    Jetmeter::DateFilter.new
  end

  def test_apply_to_event_created_before_configured_start_date
    flow = build_flow(start_at: Date.new(2017, 5, 11))
    event = OpenStruct.new(
      created_at: DateTime.iso8601('2017-05-10T00:00')
    )
    assert(build_filter.apply?(event, flow))
  end

  def test_does_not_apply_to_event_when_no_configured_start_date
    flow = build_flow
    event = OpenStruct.new(
      created_at: DateTime.iso8601('2017-05-10T00:00')
    )
    refute(build_filter.apply?(event, flow))
  end

  def test_does_not_apply_to_event_created_after_start_date
    flow = build_flow(start_at: Date.new(2017, 5, 11))
    event = OpenStruct.new(
      created_at: DateTime.iso8601('2017-05-11T10:00')
    )
    refute(build_filter.apply?(event, flow))
  end
end
