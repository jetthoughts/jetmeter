module Jetmeter
  class Collection < SimpleDelegator
    def initialize(inner_collection, adapter_class)
      super(inner_collection.map { |el| adapter_class.new(el) })
    end
  end
end
