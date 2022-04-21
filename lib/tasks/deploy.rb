require 'forwardable'
require Rails.root.join('lib/tasks/deploy_helper')

module Deploy
  extend DeployHelper

  def self.markdown_files(relation)
    table = build_table(relation)
    table_to_markdown(table).keys + relation_to_markdown(table).keys
  end

  def self.execute(uuids, relation)
    table = build_table(relation)

    ActiveRecord::Base.transaction do
      uuids.each do |uuid|
        uuid_default = YAML.load_file("#{uuid}/default.yml").with_indifferent_access

        instance = table.find_or_instantize(uuid.basename.to_s)

        ids = instance.__send__(table.relation_name).pluck(:id)
        table_attr = table_to_attributes(uuid, table)
        relation_attr = relation_to_attributes(uuid, table, ids)

        instance.attributes = table.assign_attributes(table_attr, relation_attr).merge(uuid_default.slice(:exam_type, :category))
        instance.save

        [*1..4].each do |index|
          instance.__send__("answer_#{index}_id=", nil)
        end

        uuid_default[:answer].each {|index|
          instance.__send__("answer_#{index}_id=", instance.option_masters[index - 1].id)
        }

        instance.save
      end
    end
  end

  def self.build_table(relation)
    table = AbstractTable.new(relation['table']['primary_key'], relation['table']['name'], *relation['table']['columns'])

    if relation['has_many']
      has_many = relation['has_many']
      child_table = AbstractTable.new(relation['table']['primary_key'], has_many['table']['name'], *has_many['table']['columns'])

      table.has_many(child_table, has_many['limit'])
    end

    table
  end

  class AbstractTable
    attr_reader :primary_key, :table_name, :columns, :relation

    def initialize(primary_key, table_name, *columns)
      @primary_key = primary_key
      @table_name = table_name
      @klass = table_name.classify.constantize
      @columns = columns
      @attr_template = {}.with_indifferent_access
    end

    def instantize(params = {})
      @klass.new(params)
    end

    def find(uuid)
      if relation_name
        @klass.includes(relation_name).find_by(master_uuid: uuid)
      else
        @klass.find_by(master_uuid: uuid)
      end
    end

    def find_or_instantize(uuid)
      find(uuid) || instantize({"#{primary_key}": uuid})
    end

    def has_many(table, limit)
      @relation = AbstractRelation.new(table, limit)
    end

    def attr_template
      @attr_template.dup
    end

    def assign_attributes(table_attr, relation_attr)
      [attr_template.merge(table_attr), relation_assign_attributes(relation_attr)].inject(&:merge)
    end

    def relation_limit
      @relation.limit if @relation
    end

    def relation_name
      @relation.table_name if @relation
    end

    def relation_assign_attributes(relation_attr)
      @relation ? @relation.assign_attributes(relation_attr) : {}
    end
  end

  class AbstractRelation
    extend Forwardable

    attr_reader :table, :limit

    AttrPrefix = '_attributes'

    def_delegators :@table, :primary_key, :table_name, :columns

    def initialize(table, limit)
      @table = table
      @limit = limit
      @attr_template = {"#{table_name}#{AttrPrefix}": nil}.with_indifferent_access
    end

    def assign_attributes(relation_attributes)
      attr_template = @attr_template.dup
      attr_template["#{table_name}#{AttrPrefix}"] = relation_attributes

      attr_template
    end
  end
end
