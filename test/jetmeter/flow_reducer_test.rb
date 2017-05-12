require 'minitest/autorun'
require 'jetmeter/flow_reducer'
require 'date'

class Jetmeter::FlowReducerTest < Minitest::Test
  def test_reduce_chains_self
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accomulator = TestAccomulator.new

    assert_instance_of(Jetmeter::FlowReducer, reducer.reduce(accomulator))
  end

  def test_reduce_gathers_flows
    reducer = Jetmeter::FlowReducer.new(TestEventsLoader.new)
    accomulator = TestAccomulator.new

    result = reducer.reduce(accomulator)

    assert_equal(
      ['Dev - Ready'],
      result.flows.keys
    )
  end

  def test_reduce_aggregates_events_by_date
  end
end

class TestEventsLoader
  def load
    [
      OpenStruct.new({
        id: 100,
        event: 'labeled',
        label: { name: 'Backlog' },
        issue: { number: 1 },
        created_at: Date.iso8601('2017-05-11T10:51')
      }),
      OpenStruct.new({
        id: 101,
        event: 'unlabeled',
        label: { name: 'Backlog' },
        issue: { number: 2 },
        created_at: Date.iso8601('2017-05-11T10:51')
      }),
      OpenStruct.new({
        id: 102,
        event: 'unlabeled',
        label: { name: 'Backlog' },
        issue: { number: 1 },
        created_at: Date.iso8601('2017-05-11T11:22')
      }),
      OpenStruct.new({
        id: 103,
        event: 'labeled',
        label: { name: 'Dev - Ready' },
        issue: { number: 1 },
        created_at: Date.iso8601('2017-05-11T11:23')
      }),
      OpenStruct.new({
        id: 104,
        event: 'unlabeled',
        label: { name: 'Dev - Ready' },
        issue: { number: 1 },
        created_at: Date.iso8601('2017-05-11T11:22')
      }),
      OpenStruct.new({
        id: 105,
        event: 'labeled',
        label: { name: 'Dev - Working' },
        issue: { number: 1 },
        created_at: Date.iso8601('2017-05-11T11:23')
      })
    ]
  end
end

class TestAccomulator
  def flow
    'Dev - Ready'
  end

  def selector
    ->(event) { event.label[:name] == 'Dev - Ready' }
  end

  def additive?
    true
  end
end
