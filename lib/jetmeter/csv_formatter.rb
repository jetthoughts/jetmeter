module Jetmeter
  class CsvFormatter
    def initialize(config, reducer)
      @config = config
      @reducer = reducer
      @commulative = Hash.new { |hash, flow| hash[flow] = Set.new }
      @dates = @reducer.flows.values.map(&:keys).flatten
    end

    def save(io)
      csv = CSV.new(io)
      render_header(csv)
      render_rows(csv)
    end

    private

    def render_header(csv)
      csv << ['Date'] + @config.flows.keys
    end

    def render_rows(csv)
      return if @dates.empty?

      (@dates.min..@dates.max).each do |date|
        accumulative_flow_names = []

        @config.flows.each_pair do |flow_name, flow_config|
          issues = Set.new(@reducer.flows[flow_name][date])

          @commulative[flow_name] |= issues

          accumulative_flow_names.each do |accumulative_flow_name|
            @commulative[accumulative_flow_name] |= issues
          end

          if flow_config.accumulative?
            accumulative_flow_names.push(flow_name)
          end
        end

        csv << [date.iso8601] + @commulative.values.map(&:size)
      end
    end
  end
end
