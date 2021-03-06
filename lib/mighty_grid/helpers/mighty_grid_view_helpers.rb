module MightyGrid
  module GridViewHelper
    def grid(grid, opts={}, &block)
      define_grid(grid, opts, &block)
      render_grid(grid)
    end

    def define_grid(grid, options={}, &block)

      rendering = GridRenderer.new(grid, self)

      block.call(rendering)

      table_html_attrs = options[:html] || {}
      table_html_attrs[:class] ||= ''
      table_html_classes = ["mighty-grid"] + MightyGrid.config.table_class.split(' ')
      table_html_attrs[:class] = (table_html_classes + table_html_attrs[:class].split(' ')).reject(&:blank?).join(' ')

      header_tr_html = options[:header_tr_html] || {}

      grid.read

      grid.output_buffer = content_tag :table, table_html_attrs do
        html = content_tag :thead do
          content_tag :tr, header_tr_html do
            rendering.columns.map { |column|
              content_tag :th, column.th_attrs do
                if column.options[:ordering]
                  link_to(column.title, "?#{MightyGrid::MgHash.rec_merge(grid.params, {grid.name => {order: column.attribute, order_direction: grid.order_direction}}).except('controller', 'action').to_query}").html_safe
                else
                  column.title.html_safe
                end
              end
            }.join.html_safe
          end
        end

        html += content_tag :tfoot do
          html_record = content_tag :tr do
            content_tag :td, colspan: rendering.total_columns do
              html_pag = paginate(grid.relation, theme: 'mighty_grid', param_name: "#{grid.name}[page]")
              html_pag += page_entries_info(grid.relation)
              html_pag.html_safe
            end
          end

          html_record.html_safe
        end

        html += content_tag :tbody do
          html_record = ''
          grid.relation.each do |rel|
            html_record += content_tag :tr do
              rendering.columns.map{|column| content_tag :td, column.render(rel), column.attrs}.join.html_safe
            end
          end
          html_record.html_safe
        end

        html
      end

    end

    def render_grid(grid)
      grid.output_buffer.html_safe
    end

  end
end