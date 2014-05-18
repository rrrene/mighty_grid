module MightyGrid
  class GridRenderer
    attr_reader :columns, :th_columns, :total_columns, :blank_slate_handler

    def initialize(grid, view)
      @grid = grid
      @columns = []
      @th_columns = []
      @blank_slate_handler = nil
    end

    def column(attr_or_options = {}, options=nil, &block)
      if block_given?
        options = attr_or_options.symbolize_keys
        @columns << MightyGrid::Column.new(options, &block)
      else
        attribute = attr_or_options.to_sym
        options = {} unless options.is_a?(Hash)
        opts = {
          title: @grid.klass.human_attribute_name(attribute),
          ordering: true,
          attribute: attribute
        }.merge!(options)
        @columns << MightyGrid::Column.new(attribute, opts)
      end
      @total_columns = @columns.count
    end

    def blank_slate(html_or_opts = nil, &block)
      if (html_or_opts.is_a?(Hash) && html_or_opts.has_key?(:partial) || html_or_opts.is_a?(String)) && !block_given?
        @blank_slate_handler = html_or_opts
      elsif html_or_opts.nil? && block_given?
        @blank_slate_handler = block
      else
        raise MightyGridArgumentError.new("blank_slate accepts only a string, a block, or :partial => 'path_to_partial' ")
      end
    end
  end
end