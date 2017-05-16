require 'minitest/autorun'
require 'csv'
require 'jetmeter/csv_formatter'

class Jetmeter::CsvFormatterTest < Minitest::Test
  def build_event(issue_number)
    issue_number
  end

  def test_builds_commulative_table
    flows = {
      'Backlog' => {
        Date.new(2017, 5, 9) => [build_event(1), build_event(2), build_event(3)],
        Date.new(2017, 5, 12) => [build_event(4), build_event(5)],
        Date.new(2017, 6, 1) => [build_event(6)]
      },
      'Ready' => {
        Date.new(2017, 5, 9) => [build_event(1), build_event(2)],
        Date.new(2017, 5, 10) => [build_event(3)]
      },
      'WIP' => {
        Date.new(2017, 5, 10) => [build_event(1)],
        Date.new(2017, 5, 19) => [build_event(2)],
        Date.new(2017, 6, 1) => [build_event(3)]
      },
      'Closed' => {
        Date.new(2017, 5, 22) => [build_event(2)],
        Date.new(2017, 6, 5) => [build_event(1)]
      }
    }
    io = StringIO.new('', 'wb')

    Jetmeter::CsvFormatter.new(flows).save(io)
    rows = CSV.parse(io.string)

    assert_equal(['Date',       'Backlog', 'Ready', 'WIP', 'Closed'], rows[0])
    assert_equal(['2017-05-09', '3',       '2',     '0',   '0'     ], rows[1])
    assert_equal(['2017-05-10', '3',       '3',     '1',   '0'     ], rows[2])
    # ...
    assert_equal(['2017-05-12', '5',       '3',     '1',   '0'     ], rows[4])
    # ...
    assert_equal(['2017-05-19', '5',       '3',     '2',   '0'     ], rows[11])
    # ...
    assert_equal(['2017-05-22', '5',       '3',     '2',   '1'     ], rows[14])
    # ...
    assert_equal(['2017-06-01', '6',       '3',     '3',   '1'     ], rows[24])
    # ...
    assert_equal(['2017-06-05', '6',       '3',     '3',   '2'     ], rows[28])
  end
end
