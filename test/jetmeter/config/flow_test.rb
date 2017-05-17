require 'minitest/autorun'
require 'jetmeter/config/flow'

class Jetmeter::Config::FlowTest < Minitest::Test
  def test_stores_additions_in_additive_transitions
    flow = Jetmeter::Config::Flow.new

    flow.register_addition 'Backlog' => 'Dev - Ready'
    flow.register_addition 'Backlog' => 'Dev - Working'

    assert_equal(['Dev - Ready', 'Dev - Working'], flow.transitions(true)['Backlog'])
  end

  def test_stores_substractions_in_non_additive_transitions
    flow = Jetmeter::Config::Flow.new

    flow.register_substraction 'Backlog' => 'Dev - Ready'
    flow.register_substraction 'Backlog' => 'Dev - Working'

    assert_equal(['Dev - Ready', 'Dev - Working'], flow.transitions(false)['Backlog'])
  end

  def test_stores_start_at_filter
    flow = Jetmeter::Config::Flow.new

    flow.filters[:start_at] = Time.new(2017, 5, 11)

    assert_equal(Time.new(2017, 5, 11), flow.filters[:start_at])
  end
end
