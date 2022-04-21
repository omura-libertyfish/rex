module DeployHelper
  def table_to_markdown(table, prefix: ".md")
    HashWithIndifferentAccess.new.tap do |attributes|
      table.columns.each do |column|
        attributes.store("#{table.table_name}_#{column}#{prefix}",  {table: table.table_name, column: column})
      end
    end
  end

  def relation_to_markdown(table, prefix: ".md")
    markdown = table_to_markdown(table.relation, prefix: nil).to_a
    HashWithIndifferentAccess.new.tap do |attributes|
      markdown.product([*1..table.relation_limit]).each{|(markdown, markdown_attribute), index|
        attributes.store("#{markdown}_#{index}#{prefix}", {table: table.relation_name, column: markdown_attribute[:column], index: index})
      }
    end
  end

  def table_to_attributes(uuid, table)
    markdown_mappings = table_to_markdown(table)

    HashWithIndifferentAccess.new.tap do |column_values|
      markdown_mappings.each do |markdown, attributes|
        raw = File.read("#{uuid}/#{markdown}")
        column_values[attributes[:column].intern] = raw
      end
    end
  end

  def relation_to_attributes(uuid, table, ids)
    markdown_mappings = relation_to_markdown(table)

    [].tap do |indexed_column_values|
      markdown_mappings.group_by{|_, attributes| attributes[:index]}.each do |index, mappgins|
        column_values = {id: ids[index - 1]}
        mappgins.each do |markdown, attributes|
          raw = File.read("#{uuid}/#{markdown}")
          column_values[attributes[:column].intern] = raw
        end
        indexed_column_values << column_values
      end
    end
  end
end
