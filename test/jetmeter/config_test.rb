require 'minitest/autorun'
require 'jetmeter/config'

module Octokit; class Client; end; end

class Jetmeter::ConfigTest < Minitest::Test
  def test_configures_octokit_client_with_access_token_for_auto_pagination
    mocked_octokit = Minitest::Mock.new
    mocked_client = Minitest::Mock.new
    mocked_octokit.expect(:new, mocked_client, [{ access_token: '<GITHUB_ACCESS_TOKEN>' }])
    mocked_client.expect(:auto_paginate=, {}, [true])

    config = Jetmeter::Config.new(api: mocked_octokit) do |c|
      c.github_credentials = { access_token: '<GITHUB_ACCESS_TOKEN>' }
    end
    config.client

    mocked_client.verify
    mocked_octokit.verify
  end

  def test_configures_repository_name
    config = Jetmeter::Config.new do |c|
      c.repository_name = 'marchi-martius/jetmeter'
    end

    assert_equal('marchi-martius/jetmeter', config.repository_name)
  end

  def test_configures_output_path
    config = Jetmeter::Config.new do |c|
      c.output_path = '/tmp/test.csv'
    end

    assert_equal('/tmp/test.csv', config.output_path)
  end

  def test_registers_flows
    config = Jetmeter::Config.new do |c|
      c.register_flow 'Dev - Ready' do |f|
      end
    end

    assert_includes(config.flows.keys, 'Dev - Ready')
  end

  def test_registers_flow_with_addition_transitions
    config = Jetmeter::Config.new do |c|
      c.register_flow 'Backlog' do |f|
        f.register_addition nil => 'Backlog'
      end
    end

    assert_equal(['Backlog'], config.flows['Backlog'].additions[nil])
  end

  def test_registers_flow_with_substruction_transitions
    config = Jetmeter::Config.new do |c|
      c.register_flow 'WIP' do |f|
        f.register_substraction 'Dev - Working' => 'Dev - Ready'
      end
    end

    assert_equal(['Dev - Ready'], config.flows['WIP'].substractions['Dev - Working'])
  end

  def test_registers_flow_with_filters
    config = Jetmeter::Config.new do |c|
      c.register_flow 'WIP' do |f|
        f.filters[:start_at] = Date.new(2017, 4, 10)
      end
    end

    assert_equal(Date.new(2017, 4, 10), config.flows['WIP'].filters[:start_at])
  end

  def test_register_flow_without_filters
    config = Jetmeter::Config.new do |c|
      c.register_flow 'Backlog' do |f|
      end

      c.register_flow 'WIP' do |f|
        f.filters[:start_at] = Date.new(2017, 4, 10)
      end
    end

    assert(config.flows['Backlog'].filters.empty?)
  end

  def test_raises_error_if_no_block_passed
    assert_raises(ArgumentError) { Jetmeter::Config.new }
  end
end
