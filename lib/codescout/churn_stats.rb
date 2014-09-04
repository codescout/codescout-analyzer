require "churn/calculator"

module Codescout
  class ChurnStats
    OPTIONS = {
      minimum_churn_count: 1,
      start_date: nil
    }

    attr_reader :files

    def initialize(analyzer)
      @analyzer = analyzer
      @files    = {}

      generate_report
      collect_results
    end

    private

    def generate_report
      @churn = Churn::ChurnCalculator.new(OPTIONS)
      @churn.report
    end

    def collect_results
      @churn.instance_variable_get("@changes").each do |c|
        next unless @analyzer.valid_file?(c[:file_path])
        @files[c[:file_path]] = c[:times_changed]
      end
    end
  end
end