module Codescout
  class BrakemanStats
    attr_reader :results

    def initialize(analyzer)
      @results = []

      collect_results if generate_report
    end

    private

    def generate_report
      `brakeman -f json -o brakeman.json`
      $?.success?
    end

    def report
      JSON.load(File.read("brakeman.json"))
    end

    def collect_results
      @results = report["warnings"]
    end
  end
end