require 'minitest/autorun'
require 'jetmeter/config/client_middleware'

class Jetmeter::Config::ClientMiddlewareTest < Minitest::Test
  def test_raises_error_if_no_cache_path_passed
    assert_raises(ArgumentError) do
      Jetmeter::Config::ClientMiddleware.build(nil)
    end
  end
end
