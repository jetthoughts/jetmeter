require 'minitest/autorun'
require 'jetmeter/collection'

class Jetmeter::CollectionTest < Minitest::Test
  Adapter = Class.new(SimpleDelegator)

  def test_each_decorates_elements_with_adapters
    array = [1, 3, 'hello']
    collection = Jetmeter::Collection.new(array, Adapter)

    collection.each.with_index do |element, index|
      assert_instance_of(Adapter, element)
      assert_equal(array[index], element)
    end
  end
end
