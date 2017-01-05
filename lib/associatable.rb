require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions

  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    table_name = self.class_name.downcase.pluralize
    if table_name == "humen"
      table_name = "humans"
    end
    table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.class_name = options[:class_name] || name.to_s.singularize.camelcase
    self.foreign_key = options[:foreign_key] || (name.to_s.underscore).concat("_id").to_sym
    self.primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.class_name = options[:class_name] || name.to_s.singularize.camelcase
    self.foreign_key = options[:foreign_key] || (self_class_name.to_s.underscore).concat("_id").to_sym
    self.primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      model_class = options.model_class
      model = model_class.where(options.primary_key => foreign_key).first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      primary_key = self.send(options.primary_key)
      model_class = options.model_class
      model = model_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc ||= {}
  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

    through_table = through_options.table_name
    through_primary_key = through_options.primary_key
    through_foreign_key = through_options.foreign_key

    source_table = source_options.table_name
    source_primary_key = source_options.primary_key
    source_foreign_key = source_options.foreign_key

    foreign_key = self.send(through_foreign_key)

    this_search = DBConnection.execute(<<-SQL, foreign_key)
      SELECT
        #{source_table}.*
      FROM
        #{through_table}
      JOIN
        #{source_table}
      ON
        #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
      WHERE
        #{through_table}.#{through_primary_key} = ?
    SQL

    source_options.model_class.parse_all(this_search).first

    end

  end

end

class SQLObject
  extend Associatable
end
