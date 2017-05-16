require 'minitest/autorun'
require 'jetmeter/flow_reducer'

require_relative 'test_events_loader'

class Jetmeter::FlowReducerTest < Minitest::Test
  def test_reduce_chains_self
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accumulator = TestAccumulator.new

    result = reducer.reduce('Backlog', accumulator)

    assert_instance_of(Jetmeter::FlowReducer, result)
  end

  def test_reduce_gathers_accomulated_flows
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accumulator = TestAccumulator.new

    result = reducer.reduce('Dev - Ready', accumulator)

    assert_equal(
      ['Dev - Ready'],
      result.flows.keys
    )
  end

  def test_reduce_aggregates_events_by_date
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accumulator = TestAccumulator.new

    result = reducer.reduce('Dev - Ready', accumulator)

    assert_equal(
      [Date.new(2017, 5, 11), Date.new(2017, 5, 12)],
      result.flows['Dev - Ready'].keys
    )
  end

  def test_reduce_pushes_additive_and_deletes_substractions
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accumulator = TestAccumulator.new

    assert_equal(0, reducer.flows.values.flatten.count)

    reducer = reducer.reduce('Dev - Ready', accumulator)

    assert_equal(2, reducer.flows['Dev - Ready'].values.flatten.count)

    accumulator.additive = false
    reducer = reducer.reduce('Dev - Ready', accumulator)

    assert_equal(0, reducer.flows['Dev - Ready'].values.flatten.count)
  end

  def test_reduce_all_chains_self
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accumulator = TestAccumulator.new

    result = reducer.reduce_all(['Backlog', 'Dev - Working'], [accumulator])

    assert_instance_of(Jetmeter::FlowReducer, result)
  end

  def test_reduce_all_applies_all_flows_to_all_accumulators
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)

    accumulator1 = Minitest::Mock.new
    accumulator1.expect(:selector, Proc.new {}, ['Backlog'])
    accumulator1.expect(:selector, Proc.new {}, ['Dev - Working'])

    accumulator2 = Minitest::Mock.new
    accumulator2.expect(:selector, Proc.new {}, ['Backlog'])
    accumulator2.expect(:selector, Proc.new {}, ['Dev - Working'])

    reducer.reduce_all(['Backlog', 'Dev - Working'], [accumulator1, accumulator2])

    accumulator1.verify
    accumulator2.verify
  end

  def test_merge_joins_flows
    first = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    second = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accumulator = TestAccumulator.new

    first.reduce('Backlog', accumulator)
    first.reduce('Dev - Ready', accumulator)
    second.reduce('Backlog', accumulator)

    first.merge(second)

    assert_equal(6, first.flows['Backlog'][Date.new(2017, 5, 11)].count)
  end
end

class TestAccumulator
  attr_accessor :additive

  def initialize
    @additive = true
  end

  def selector(flow)
    ->(event) { event.label[:name] == flow }
  end
end
