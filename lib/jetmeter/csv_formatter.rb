module Jetmeter
  class CsvFormatter
    def initialize(config, reducer)
      @config = config
      @reducer = reducer
      @commulative = Hash.new { |hash, flow| hash[flow] = 0 }
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
        @config.flows.keys.each do |flow_name|
          events = @reducer.flows[flow_name].fetch(date, []).uniq
          @commulative[flow_name] += events.length
        end
        csv << [date.iso8601] + @commulative.values
      end
    end
  end
end
