require 'minitest/autorun'
require 'jetmeter/flow_reducer'

require_relative '../helpers/test_events_loader'

class Jetmeter::FlowReducerTest < Minitest::Test
  def build_flow_config
    OpenStruct.new
  end

  def setup
    @config = OpenStruct.new(
      flows: {
        'Backlog' => build_flow_config,
        'Dev - Ready' => build_flow_config
      }
    )
    @reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new, @config)
  end

  def test_reduces_configured_flows
    accumulators = [
      TestAccumulator.new('Dev - Ready'),
      TestAccumulator.new('Backlog'),
      TestAccumulator.new('Unknown')
    ]
    @reducer.reduce(accumulators, [])

    assert_equal(
      ['Backlog', 'Dev - Ready'],
      @reducer.flows.keys
    )
  end

  def test_reduce_aggregates_events_by_date
    accumulator = TestAccumulator.new('Dev - Ready')

    @reducer.reduce([accumulator], [])

    assert_equal(
      [Date.new(2017, 5, 11), Date.new(2017, 5, 12)],
      @reducer.flows['Dev - Ready'].keys
    )
  end

  def test_reduce_pushes_additive_and_deletes_substractions
    accumulator = TestAccumulator.new('Dev - Ready')

    assert_equal(0, @reducer.flows.values.flatten.count)

    @reducer.reduce([accumulator], [])
    assert_equal(2, @reducer.flows['Dev - Ready'].values.flatten.count)

    accumulator.additive = false
    @reducer.reduce([accumulator], [])

    assert_equal(0, @reducer.flows['Dev - Ready'].values.flatten.count)
  end

  def test_merge_joins_flows
    first = Jetmeter::FlowReducer.new(TestEventsLoader.new, @config)
    second = Jetmeter::FlowReducer.new(TestEventsLoader.new, @config)
    backlog_accumulator = TestAccumulator.new('Backlog')
    ready_accumulator = TestAccumulator.new('Dev - Ready')

    first.reduce([backlog_accumulator, ready_accumulator], [])
    second.reduce([backlog_accumulator], [])

    first.merge(second)

    assert_equal(7, first.flows['Backlog'][Date.new(2017, 5, 11)].count)
  end
end

class TestAccumulator
  attr_accessor :additive

  def initialize(label_name)
    @additive = true
    @label_name = label_name
  end

  def valid?(event, flow)
    event.label[:name] == @label_name
  end
end
