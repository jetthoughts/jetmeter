module Jetmeter
  class Config
    class Flow
      attr_reader :additions
      attr_reader :substractions
      attr_accessor :filters
      attr_writer :accumulative

      def initialize
        @additions = Hash.new { |hash, key| hash[key] = [] }
        @substractions = Hash.new { |hash, key| hash[key] = [] }
        @filters = {}
        @accumulative = true
      end

      def register_addition(hash)
        hash.each_pair do |key, value|
          @additions[key] << value
        end
      end

      def register_substraction(hash)
        hash.each_pair do |key, value|
          @substractions[key] << value
        end
      end

      def transitions(additive)
        additive ? additions : substractions
      end

      def accumulative?
        !!@accumulative
      end
    end
  end
end
