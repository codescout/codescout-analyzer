module Codescout
  class RubocopStats
    attr_reader :results

    def initialize(analyzer)
      @analyzer = analyzer
      @results  = {}

      install_config

      `rubocop -c rubocop.yml -f json -o rubocop.json`

      json = JSON.load(File.read("rubocop.json"))

      json["files"].each do |file|
        next unless @analyzer.files.include?(file["path"])
        next if file["offenses"].empty?

        lines = File.read(file["path"]).split("\n")

        @results[file["path"]] = select_offences(lines, file["offenses"])
      end
    end

    def select_offences(lines, offenses)
      offenses.map { |o| o["code"] = lines[o["location"]["line"] - 1] ; o }
    end

    private

    def config_path
      "#{File.dirname(__FILE__)}/../../config/rubocop.yml"
    end

    def install_config
      FileUtils.cp(config_path, "rubocop.yml")
    end
  end
end