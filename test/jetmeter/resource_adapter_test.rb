require 'minitest/autorun'
require 'jetmeter/resource_adapter'

class Jetmeter::ResourceAdapterTest < Minitest::Test
  def test_is_not_an_issue_event
    refute(Jetmeter::ResourceAdapter.new({}).issue_event?)
  end

  def test_is_not_an_issue
    refute(Jetmeter::ResourceAdapter.new({}).issue?)
  end

  def test_flow_date_not_implemented
    assert_raises(NotImplementedError) do
      Jetmeter::ResourceAdapter.new({}).flow_date
    end
  end

  def test_issue_number_not_implemented
    assert_raises(NotImplementedError) do
      Jetmeter::ResourceAdapter.new({}).issue_number
    end
  end

  def test_delegates_foo_to_resource
    resource = OpenStruct.new(foo: 'FOO')
    assert_equal('FOO', Jetmeter::ResourceAdapter.new(resource).foo)
  end
end
