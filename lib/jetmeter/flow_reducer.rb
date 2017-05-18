module Jetmeter
  class FlowReducer
    attr_reader :flows

    def initialize(resource_collections, config)
      @resource_collections = resource_collections
      @config_flows = config.flows
      @flows = Hash.new do |hash, flow_name|
        hash[flow_name] = Hash.new { |flow, date| flow[date] = [] }
      end
    end

    def reduce(accumulators, filters)
      @resource_collections.each do |resource_collection|
        resource_collection.each do |resource|
          reduce_resource(resource, accumulators, filters)
        end
      end
    end

    private

    def reduce_resource(resource, accumulators, filters)
      @config_flows.each_pair do |flow_name, flow_config|
        next if filters.any? { |filter| filter.apply?(resource, flow_config) }

        accumulators.each do |accumulator|
          if accumulator.valid?(resource, flow_config)
            apply_accumulator(resource, accumulator, flow_name)
          end
        end
      end
    end

    def apply_accumulator(resource, accumulator, flow_name)
      if accumulator.additive
        @flows[flow_name][resource.flow_date].push(resource.issue_number)
      else
        @flows[flow_name][resource.flow_date].delete(resource.issue_number)
      end
    end
  end
end
