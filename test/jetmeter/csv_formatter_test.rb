require 'minitest/autorun'
require 'csv'
require 'jetmeter/csv_formatter'

class Jetmeter::CsvFormatterTest < Minitest::Test
  def test_builds_commulative_table
    flows = {
      'Backlog' => {
        Date.new(2017, 4, 9)  => [1, 2, 3],
        Date.new(2017, 4, 10) => [4, 5, 6, 7],
        Date.new(2017, 4, 12) => [8, 9],
        Date.new(2017, 5, 12) => [10, 11, 12],
        Date.new(2017, 6, 1)  => [13]
      },
      'Ready' => {
        Date.new(2017, 5, 9)  => [1, 2]
      },
      'WIP' => {
        Date.new(2017, 5, 10) => [1, 3],
        Date.new(2017, 5, 19) => [2],
      },
      'Closed' => {
        Date.new(2017, 5, 22) => [2],
        Date.new(2017, 6, 5)  => [1, 11, 13]
      }
    }

    config = OpenStruct.new(flows: {})
    flows.keys.each do |flow_name|
      config.flows[flow_name] = OpenStruct.new(accumulative?: true)
    end
    config.flows['Backlog'][:accumulative?] = false

    reducer = OpenStruct.new(flows: flows)

    io = StringIO.new('', 'wb')
    Jetmeter::CsvFormatter.new(config, reducer).save(io)
    rows = CSV.parse(io.string)

    assert_equal(['Date',       'Backlog', 'Ready', 'WIP', 'Closed'], rows[0])
    assert_equal(['2017-05-08', '9',       '0',     '0',   '0'     ], rows[30])
    assert_equal(['2017-05-09', '9',       '2',     '0',   '0'     ], rows[31])
    assert_equal(['2017-05-10', '9',       '3',     '2',   '0'     ], rows[32])
    # ...
    assert_equal(['2017-05-12', '12',      '3',     '2',   '0'     ], rows[34])
    # ...
    assert_equal(['2017-05-19', '12',      '3',     '3',   '0'     ], rows[41])
    # ...
    assert_equal(['2017-05-22', '12',      '3',     '3',   '1'     ], rows[44])
    # ...
    assert_equal(['2017-06-01', '13',      '3',     '3',   '1'     ], rows[54])
    # ...
    assert_equal(['2017-06-05', '13',      '5',     '5',   '4'     ], rows[58])
  end
end
