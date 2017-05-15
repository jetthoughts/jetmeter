require 'date'

class TestEventsLoader
  def load
    [
      OpenStruct.new({
        id: 100,
        event: 'labeled',
        label: { name: 'Backlog' },
        issue: { number: 1 },
        created_at: DateTime.iso8601('2017-05-11T10:51')
      }),
      OpenStruct.new({
        id: 101,
        event: 'unlabeled',
        label: { name: 'Backlog' },
        issue: { number: 2 },
        created_at: DateTime.iso8601('2017-05-11T10:51')
      }),
      OpenStruct.new({
        id: 102,
        event: 'unlabeled',
        label: { name: 'Backlog' },
        issue: { number: 1 },
        created_at: DateTime.iso8601('2017-05-11T11:22')
      }),
      OpenStruct.new({
        id: 103,
        event: 'labeled',
        label: { name: 'Dev - Ready' },
        issue: { number: 1 },
        created_at: DateTime.iso8601('2017-05-11T11:23')
      }),
      OpenStruct.new({
        id: 104,
        event: 'unlabeled',
        label: { name: 'Dev - Ready' },
        issue: { number: 1 },
        created_at: DateTime.iso8601('2017-05-12T11:22')
      }),
      OpenStruct.new({
        id: 105,
        event: 'labeled',
        label: { name: 'Dev - Working' },
        issue: { number: 1 },
        created_at: DateTime.iso8601('2017-05-12T11:23')
      }),
      OpenStruct.new({
        id: 106,
        event: 'unlabeled',
        label: { name: 'Dev - Working' },
        issue: { number: 1 },
        created_at: DateTime.iso8601('2017-05-13T11:30')
      })
    ]
  end
end
