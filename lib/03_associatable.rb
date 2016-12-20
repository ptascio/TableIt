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
    options = BelongsToOptions.new(name, options)
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
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
