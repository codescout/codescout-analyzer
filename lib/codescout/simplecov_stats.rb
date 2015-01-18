require "nokogiri"

module Codescout
  class SimplecovStats
    attr_reader :files,
                :files_count,
                :coverage_percent,
                :avg_hit,
                :lines_total,
                :lines_relevant,
                :lines_missed,
                :lines_covered

    def initialize(analyzer, data)
      doc = Nokogiri::HTML(data)

      items = doc.css("#AllFiles table.file_list tbody tr").map do |el|
        item = parse_element(el)

        unless analyzer.files.include?(item[:file])
          item = nil
        end

        item
      end

      items.compact!
      items.sort! { |a, b| a[:coverage_percent] <=> b[:coverage_percent] }
      @files_count = items.size

      if items.any?
        # Calculate average hit
        sum = items.map { |f| f[:avg_hit] }.reduce(:+)
        @avg_hit = (sum / @files_count).round(2)

        # Calculate number of relevant lines
        @lines_total    = items.map { |f| f[:lines_total]    }.reduce(:+)
        @lines_covered  = items.map { |f| f[:lines_covered]  }.reduce(:+)
        @lines_relevant = items.map { |f| f[:lines_relevant] }.reduce(:+)
        @lines_missed   = items.map { |f| f[:lines_missed]   }.reduce(:+)

        # Calculate coverage percent
        @coverage_percent = ((@lines_covered * 100.00) / @lines_relevant).round(2)
      end

      @files = {}
      items.each do |item|
        @files[item.delete(:file)] = item
      end
    end

    def to_hash
      {
        files_count:      files_count,
        coverage_percent: coverage_percent,
        avg_hit:          avg_hit,
        lines_total:      lines_total,
        lines_relevant:   lines_relevant,
        lines_missed:     lines_missed,
        lines_covered:    lines_covered,
        files:            files
      }
    end

    private

    def parse_element(el)
      td = el.css("td")

      {
        file:             el.css("a.src_link").children.first.text,
        coverage_percent: Float(td[1].children.first.text.scan(/[\d\.]+/)[0]),
        lines_total:      Integer(td[2].children.first.text),
        lines_relevant:   Integer(td[3].children.first.text),
        lines_covered:    Integer(td[4].children.first.text),
        lines_missed:     Integer(td[5].children.first.text),
        avg_hit:          (Float(td[6].children.first.text) rescue 0.00)
      }
    end
  end
end