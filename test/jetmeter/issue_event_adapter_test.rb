require 'minitest/autorun'
require 'jetmeter/issue_event_adapter'
require 'date'

class IssueEventTest < Minitest::Test
  def test_is_not_an_issue
    refute(Jetmeter::IssueEventAdapter.new({}).issue?)
  end

  def test_is_an_issue_event
    assert(Jetmeter::IssueEventAdapter.new({}).issue_event?)
  end

  def test_flow_date_is_event_created_at_date
    resource = OpenStruct.new(created_at: Time.new(2017, 3, 1, 22, 10))
    adapter = Jetmeter::IssueEventAdapter.new(resource)
    assert_equal(Date.new(2017, 3, 1), adapter.flow_date)
  end

  def test_issue_number_is_events_issue_number
    issue    = OpenStruct.new(number: 444)
    resource = OpenStruct.new(issue: issue)
    adapter = Jetmeter::IssueEventAdapter.new(resource)
    assert_equal(444, adapter.issue_number)
  end
end
