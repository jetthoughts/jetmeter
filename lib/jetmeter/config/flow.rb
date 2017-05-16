module Jetmeter
  class Config
    class Flow
      attr_reader :additions
      attr_reader :substractions

      def initialize(opening: false, closing: false)
        @additions = Hash.new { |hash, key| hash[key] = [] }
        @substractions = Hash.new { |hash, key| hash[key] = [] }
        @opening = opening
        @closing = closing
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

      def opening?
        !!@opening
      end

      def closing?
        !!@closing
      end
    end
  end
end
