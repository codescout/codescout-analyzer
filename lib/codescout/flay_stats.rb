require "flay"

module Codescout
  class FlayStats
    OPTIONS = {
      :diff    => true,
      :mass    => 16,
      :summary => false,
      :verbose => false,
      :number  => true,
      :timeout => 10,
      :liberal => false,
      :fuzzy   => false,
      :only    => nil
    }

    attr_reader :matches

    def initialize(analyzer)
      @matches   = []
      @base_path = analyzer.base_path

      @flay = Flay.new(OPTIONS)
      @flay.process(*analyzer.files)
      
      process_matches(@flay.analyze)
      @flay = nil
    end

    private

    def process_matches(items)
      items.each_with_index do |item, count|
        match_item = {
          match: item.identical? ? "identical" : "similar",
          node:  item.name.to_s,
          bonus: item.bonus ? item.bonus.sub("*", "").to_i : nil,
          mass:  item.mass,
          locations: locations(item)
        }

        nodes = @flay.hashes[item.structural_hash]

        sources = nodes.map do |s|
          msg = "sexp_to_#{File.extname(s.file).sub(/./, '')}"
          @flay.respond_to?(msg) ? @flay.send(msg, s) : @flay.sexp_to_rb(s)
        end

        diff = @flay.n_way_diff(*sources)

        parse_diff(diff, item.locations.size).each_with_index do |code,i|
          match_item[:locations][i][:code] = code
        end

        @matches << match_item
      end
    end

    def locations(item)
      item.locations.map do |l|
        {
          file: l.file.sub("#{@base_path}/", ""),
          line: l.line
        }
      end
    end

    def parse_diff(diff, size)
      chunks = Array.new(size) { [] }

      diff.split("\n").each do |line|
        if line =~ /^([^:]):\s?(.+)/
          key = ($1.ord - ?A.ord).to_i
          chunks[key] << $2
        else
          chunks.each_with_index do |_,i|
            chunks[i] << line.gsub(/^\s{3}/, "")
          end
        end
      end

      chunks.map { |c| c.join("\n") }
    end
  end
end