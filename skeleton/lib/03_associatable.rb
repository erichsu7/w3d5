require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    (class_name + "s").downcase
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.classify
    @foreign_key = options[:foreign_key] || name.to_s.foreign_key.to_sym
    @primary_key = options[:primary_key] || :id

    assoc_options[name] = self
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.classify
    @foreign_key = options[:foreign_key] || (self_class_name.to_s + "_id").downcase.to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      foreign_key_value = self.send(options.foreign_key)
      options.model_class.where({ options.primary_key => foreign_key_value }).first
    end
  end


  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      primary_key_value = self.send(options.primary_key)
      options.model_class.where({ options.foreign_key => primary_key_value })
    end
  end

  def assoc_options
    @assoc_options || @assoc_options = {}
  end
end

class SQLObject
  extend Associatable
end
