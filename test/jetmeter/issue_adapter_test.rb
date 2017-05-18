require 'minitest/autorun'
require 'jetmeter/issue_adapter'
require 'date'

class IssueAdapterTest < Minitest::Test
  def test_is_an_issue
    assert(Jetmeter::IssueAdapter.new({}).issue?)
  end

  def test_is_not_an_issue_event
    refute(Jetmeter::IssueAdapter.new({}).issue_event?)
  end

  def test_flow_date_is_issues_created_at_date
    resource = OpenStruct.new(created_at: Time.new(2017, 5, 12, 13, 5))
    adapter = Jetmeter::IssueAdapter.new(resource)
    assert_equal(Date.new(2017, 5, 12), adapter.flow_date)
  end

  def test_issue_number_is_self_number
    resource = OpenStruct.new(number: 345)
    adapter = Jetmeter::IssueAdapter.new(resource)
    assert_equal(345, adapter.issue_number)
  end

  def test_delegates_fields_to_self
    resource = OpenStruct.new(fields: Set.new([:foo, :bar, :baz]))
    adapter = Jetmeter::IssueAdapter.new(resource)
    assert_equal(Set.new([:foo, :bar, :baz]), adapter.fields)
  end
end
