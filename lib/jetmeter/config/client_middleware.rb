module Jetmeter
  class Config
    class ClientMiddleware
      def self.build(cache_path)
        raise ArgumentError unless cache_path

        store = Jetmeter::Config::FileCacheStore.new(cache_path)

        Faraday::RackBuilder.new do |builder|
          builder.use Faraday::HttpCache, store: store, serializer: Marshal, shared_cache: false
          builder.use Octokit::Response::RaiseError
          builder.adapter Faraday.default_adapter
        end
      end
    end
  end
end
