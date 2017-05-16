module Jetmeter
  class CsvFormatter
    def initialize(flows)
      @flows = flows
      @commulative = Hash.new { |hash, flow| hash[flow] = 0 }
      @dates = @flows.values.map(&:keys).flatten
    end

    def save(io)
      csv = CSV.new(io)
      render_header(csv)
      render_rows(csv)
    end

    private

    def render_header(csv)
      csv << ['Date'] + @flows.keys
    end

    def render_rows(csv)
      return if @dates.empty?

      (@dates.min..@dates.max).each do |date|
        @flows.each do |flow, dates|
          events = dates.fetch(date, []).uniq
          @commulative[flow] += events.count
        end
        csv << [date.iso8601] + @commulative.values
      end
    end
  end
end
