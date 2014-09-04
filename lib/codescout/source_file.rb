require "parser/current"

module Codescout
  class SourceFile
    class ObjectMethod
      attr_reader :line, :line_end
      attr_reader :code

      def initialize(exp)
        @line     = exp.begin.line
        @line_end = exp.end.line
        @code     = exp.source
      end
    end

    def initialize(code)
      @parser = Parser::CurrentRuby.parse(code)
    end

    def method_source(method_name)
      @method_source = nil

      recursive_search_ast(@parser, method_name) do |exp|
        @method_source = ObjectMethod.new(exp)
      end
      
      @method_source
    end

    def method_lines(method_name)
      @method_lines = nil

      recursive_search_ast(@parser, method_name) do |exp|
        @method_lines = exp.begin.line, exp.end.line
      end

      @method_lines
    end

    private

    def recursive_search_ast(ast, method_name, &blk)
      ast.children.each do |child|
        if child.kind_of?(Parser::AST::Node)
          if (child.type.to_s == "def" || child.type.to_s == "defs")
            if child.children[0].to_s == method_name || child.children[1].to_s == method_name
              blk.call(child.loc.expression)
            end
          else
            recursive_search_ast(child, method_name, &blk)
          end
        end
      end
    end
  end
end