require "flog"

module Codescout
  class FlogStats
    attr_reader :score, :average_score
    attr_reader :scores

    def initialize(analyzer)
      options = {
        all: true,
        methods: true,
        continue: true
      }

      @flog = Flog.new(options)
      @flog.flog(*analyzer.files)
      @flog.calculate

      @score         = @flog.total_score
      @average_score = @flog.average
      @scores        = {}

      @flog.mass.each_pair do |file, mass|
        @scores[file] = { score: 0, scores: [] }
      end

      @flog.totals.each_pair do |k,v|
        next if @flog.method_locations[k].nil?

        score = v.round
        class_name, method_name = parse_method_string(k)
        path, line = @flog.method_locations[k].split(":")
        code = nil

        if score >= 25 && method_name
          method_source = Codescout::SourceFile.new(File.read(path)).method_source(method_name)

          if method_source
            code = method_source.code
          end
        end

        @scores[path][:score] += score

        @scores[path][:scores] << {
          class_name:  class_name,
          method_name: method_name,
          score:       score,
          line:        line,
          code:        code
        }
      end

      @flog = nil
    end

    private

    def parse_method_string(str)
      chunks = str.split("#")
      klass  = extract_class(chunks[0])
      method = chunks[1]

      # Parse class method, they're prefixed with "::"
      if method.nil?
        method = chunks[0].split("::").last
      end

      # Allow only properly formatter method names in ruby.
      # Anything that looks like DSL or sugar does not have a method name.
      if invalid_def?(method)
        method = nil
      end

      return klass, method
    end

    def extract_class(str)
      str.split("::").reject { |c| c =~ /^[^A-Z]/ }.join("::")
    end

    def invalid_def?(str)
      str =~ /[\/\(\)]/ ? true : false
    end
  end
end