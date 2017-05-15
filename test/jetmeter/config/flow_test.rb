require 'minitest/autorun'
require 'jetmeter/config/flow'

class Jetmeter::Config::FlowTest < Minitest::Test
  def test_stores_additions_in_hash
    flow = Jetmeter::Config::Flow.new

    flow.register_addition 'Backlog' => 'Dev - Ready'
    flow.register_addition 'Backlog' => 'Dev - Working'

    assert_equal(['Dev - Ready', 'Dev - Working'], flow.additions['Backlog'])
  end
end
