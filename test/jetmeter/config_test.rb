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

  def test_raises_error_if_no_block_passed
    assert_raises(ArgumentError) { Jetmeter::Config.new }
  end
end
