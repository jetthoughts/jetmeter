module Jetmeter
  class CsvFormatter
    def initialize(flows)
      @flows = flows
      @commulative = Hash.new { |hash, flow| hash[flow] = 0 }

      dates = @flows.values.map(&:keys).flatten
      @start_date  = dates.min
      @finish_date = dates.max
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
      (@start_date..@finish_date).each do |date|
        @flows.keys.each do |flow|
          events = @flows[flow].fetch(date, []).uniq { |e| e.issue[:number] }
          @commulative[flow] += events.count
        end
        csv << [date.iso8601] + @commulative.values
      end
    end
  end
end
