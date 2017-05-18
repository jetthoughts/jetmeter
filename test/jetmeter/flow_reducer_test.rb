require 'minitest/autorun'
require 'jetmeter/flow_reducer'
require 'date'

require_relative '../helpers/test_flow'

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

class Jetmeter::FlowReducerTest < Minitest::Test
  def build_flow_config
    TestFlow.new
  end

  def setup
    @config = OpenStruct.new(
      flows: {
        'Backlog' => build_flow_config,
        'Dev - Ready' => build_flow_config
      }
    )
    resources = [
      OpenStruct.new({
        id: 100,
        issue_event?: true,
        event: 'labeled',
        label: { name: 'Backlog' },
        issue_number: 1,
        flow_date: Date.iso8601('2017-05-11T10:51')
      }),
      OpenStruct.new({
        id: 101,
        issue_event?: true,
        event: 'unlabeled',
        label: { name: 'Backlog' },
        issue_number: 2,
        flow_date: Date.iso8601('2017-05-11T10:51')
      }),
      OpenStruct.new({
        id: 102,
        issue_event?: true,
        event: 'unlabeled',
        label: { name: 'Backlog' },
        issue_number: 1,
        flow_date: Date.iso8601('2017-05-11T11:22')
      }),
      OpenStruct.new({
        id: 103,
        event: 'labeled',
        issue_event?: true,
        label: { name: 'Dev - Ready' },
        issue_number: 1,
        flow_date: Date.iso8601('2017-05-11T11:23')
      }),
      OpenStruct.new({
        id: 104,
        event: 'unlabeled',
        issue_event?: true,
        label: { name: 'Dev - Ready' },
        issue_number: 1,
        flow_date: Date.iso8601('2017-05-12T11:22')
      }),
      OpenStruct.new({
        id: 105,
        event: 'labeled',
        issue_event?: true,
        label: { name: 'Dev - Working' },
        issue_number: 1,
        flow_date: Date.iso8601('2017-05-12T11:23')
      }),
      OpenStruct.new({
        id: 106,
        event: 'unlabeled',
        issue_event?: true,
        label: { name: 'Dev - Working' },
        issue_number: 1,
        flow_date: Date.iso8601('2017-05-13T11:30')
      })
    ]
    @reducer = Jetmeter::FlowReducer.new([resources], @config)
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
end
