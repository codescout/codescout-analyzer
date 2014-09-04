module Codescout
  class FileStats
    PATTERNS = {
      line_comment:        /^\s*#/,
      begin_block_comment: /^=begin/,
      end_block_comment:   /^=end/,
      class:               /^\s*class\s+[_A-Z]/,
      method:              /^\s*def\s+[_a-z]/,
    }

    attr_reader :file_size,     # File size in bytes
                :lines,         # Total number of lines
                :loc,           # Number of code lines
                :method_loc,    # Average lines of code per method
                :classes_count, # Number of class definitions
                :methods_count  # Number of methods definitions

    def initialize(base_path, path)
      @path      = path
      @full_path = File.join(base_path, path)

      init_metrics
      calculate_file_metrics
      calculate_code_metrics
    end

    def to_hash
      {
        file_size:     file_size,
        lines:         lines,
        loc:           loc,
        method_loc:    method_loc,
        classes_count: classes_count,
        methods_count: methods_count
      }
    end

    private

    def init_metrics
      @file_size     = 0
      @lines         = 0
      @loc           = 0
      @method_loc    = 0
      @classes_count = 0
      @methods_count = 0
    end

    def calculate_file_metrics
      @file_size = File.size(@full_path)
    end

    def calculate_code_metrics
      io              = File.open(@full_path)
      patterns        = PATTERNS
      comment_started = false

      while line = io.gets
        @lines += 1

        if comment_started
          if patterns[:end_block_comment] && line =~ patterns[:end_block_comment]
            comment_started = false
          end
          next
        else
          if patterns[:begin_block_comment] && line =~ patterns[:begin_block_comment]
            comment_started = true
            next
          end
        end

        @classes_count += 1 if patterns[:class] && line =~ patterns[:class]
        @methods_count += 1 if patterns[:method] && line =~ patterns[:method]

        if line !~ /^\s*$/ && (patterns[:line_comment].nil? || line !~ patterns[:line_comment])
          @loc += 1
        end
      end

      @method_loc = @methods_count > 0 ? @loc / @methods_count : 0
    end
  end
end