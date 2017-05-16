require 'minitest/autorun'
require 'jetmeter/config/flow'

class Jetmeter::Config::FlowTest < Minitest::Test
  def test_stores_additions_in_hash
    flow = Jetmeter::Config::Flow.new

    flow.register_addition 'Backlog' => 'Dev - Ready'
    flow.register_addition 'Backlog' => 'Dev - Working'

    assert_equal(['Dev - Ready', 'Dev - Working'], flow.additions['Backlog'])
  end

  def test_stores_substractions_in_hash
    flow = Jetmeter::Config::Flow.new

    flow.register_substraction 'Backlog' => 'Dev - Ready'
    flow.register_substraction 'Backlog' => 'Dev - Working'

    assert_equal(['Dev - Ready', 'Dev - Working'], flow.substractions['Backlog'])
  end

  def test_default_flow_is_not_closing
    refute(Jetmeter::Config::Flow.new.closing?)
  end

  def test_create_closing
    assert(Jetmeter::Config::Flow.new(closing: true).closing?)
  end

  def test_default_flow_is_not_opening
    refute(Jetmeter::Config::Flow.new.opening?)
  end

  def test_create_opening
    assert(Jetmeter::Config::Flow.new(opening: true).opening?)
  end
end
