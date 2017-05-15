module Jetmeter
  ACCUM = {
    nil => 'Backlog',
    'Backlog' => 'Dev - Ready',
    'Dev - Ready' => 'Dev - Working',
    'Dev - Working' => 'QA - Ready',
    'QA - Ready' => 'QA - Working'
  }
  DISCARD = {
    'Dev - Working' => 'Dev - Ready',
    'QA - Ready' => 'Dev - Working'
  }

  def self.run
    config = Config.new
    events_loader = RepositoryIssueEventsLoader.new(config)

    reducer = FlowReducer.new(events_loader)
    accomulators = [
      LabelAccumulator.new(events_loader, config),
      LabelAccumulator.new(events_loader, config, additive: false),
      CloseAccumulator.new(config)
    ]

    reducer = reducer.reduce_all(config.flows.keys, accumulators)
    CsvFormatter.new(reducer.flows).save(config.csv_path)
  end
end

require 'octokit'
require 'jetmeter/version'
require 'jetmeter/config'
require 'jetmeter/repository_issue_events_loader'
require 'jetmeter/flow_reducer'
require 'jetmeter/label_accumulator'
require 'jetmeter/close_accumulator'
