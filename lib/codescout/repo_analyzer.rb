module Codescout
  class RepoAnalyzer
    ALLOWED_FILES = %w(.rb .rake .gemspec)

    attr_reader :base_path, :files

    def initialize(path)
      @base_path = File.expand_path(path)
      @files = []
      @codescout = {
        version: Codescout::VERSION
      }
    end

    def analyze
      within_base do
        scan_files
        run_filestats
        run_flog
        run_flay
        run_churn
        run_brakeman
        run_rubocop
      end
    end

    def result
      {
        codescout:  @codescout,
        file_stats: @file_stats,
        flog:       @flog,
        flay:       @flay,
        churn:      @churn,
        brakeman:   @brakeman,
        rubocop:    @rubocop
      }
    end

    def within_base(&blk)
      Dir.chdir(@base_path) { blk.call }
    end

    def scan_files
      Dir["**/*"].each { |file| @files << file if valid_file?(file) }
    end

    def run_flay
      STDERR.puts "Running flay"
      @flay = Codescout::FlayStats.new(self).matches
    end

    def run_flog
      STDERR.puts "Running flog"
      @flog = Codescout::FlogStats.new(self).scores
    end

    def run_filestats
      STDERR.puts "Running filestats"
      @file_stats = {}

      @files.each do |f|
        @file_stats[f] = Codescout::FileStats.new(@base_path, f).to_hash
      end

      if File.exists?("Gemfile")
        @file_stats["Gemfile"] = Codescout::FileStats.new(@base_path, "Gemfile").to_hash
      end
    end

    def run_churn
      STDERR.puts "Running churn"
      @churn = Codescout::ChurnStats.new(self).files
    end

    def run_brakeman
      STDERR.puts "Running brakeman"
      @brakeman = Codescout::BrakemanStats.new(self).results
    end

    def run_rubocop
      STDERR.puts "Running rubocop"
      @rubocop = Codescout::RubocopStats.new(self).results
    end

    def valid_file?(file)
      return false unless ALLOWED_FILES.include?(File.extname(file))
      return false if file =~ /^db|spec|features|test|examples|samples\//
      true
    end
  end
end