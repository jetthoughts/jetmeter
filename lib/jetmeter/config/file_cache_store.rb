module Jetmeter
  class Config
    class FileCacheStore
      def initialize(root_path)
        raise ArgumentError unless File.exist?(root_path)
        raise ArgumentError unless File.directory?(root_path)
        raise ArgumentError unless File.writable?(root_path)

        @root_path = root_path
      end

      def read(key)
        if readable?(key)
          File.open(path(key)) { |f| Marshal.load(f) }
        end
      end

      def write(key, value)
        File.open(path(key), 'wb') { |f| Marshal.dump(value, f) }
      end

      def delete(key)
        if File.exist?(path(key))
          File.delete(path(key))
        end
      end

      private

      def path(key)
        File.join(@root_path, Digest::MD5.hexdigest(key))
      end

      def readable?(key)
        File.exist?(path(key)) && File.readable?(path(key))
      end
    end
  end
end
