module Jetmeter
  class CsvFormatter
    def initialize(flows)
      @flows = flows
      @commulative = Hash.new { |hash, flow| hash[flow] = 0 }
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
      dates = @flows.values.map(&:keys).flatten
      return if dates.empty?

      (dates.min..dates.max).each do |date|
        @flows.keys.each do |flow|
          events = @flows[flow].fetch(date, []).uniq
          @commulative[flow] += events.count
        end
        csv << [date.iso8601] + @commulative.values
      end
    end
  end
end
