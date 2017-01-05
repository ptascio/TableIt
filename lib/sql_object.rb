require_relative 'db_connection'
require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'
require 'byebug'


class SQLObject

  def self.columns
    return @columns if @columns
    column_names = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
      SQL
    column_names.map! { |str| str.to_sym }
    @columns = column_names
  end


  def attributes
    @attributes ||= {}
  end

  def self.finalize!
    columns.each do |clm|
      define_method(clm) do
         self.attributes[clm]
      end
       define_method("#{clm}=".to_sym) do |arg|
           self.attributes[clm] = arg
        end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    if @table_name.nil?
      @table_name = self.to_s.downcase.tableize
    end
    @table_name
  end

  def self.all
     hashes = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
     SQL

     parse_all(hashes)
  end

  def self.parse_all(results)

    all_objects = []
    results.each do |rslt|
      all_objects << self.new(rslt)
    end
    all_objects
  end

  def self.find(id)
     this_query = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
     SQL
     return nil if this_query.empty?
     self.new(this_query.first)
  end

  def self.first
    self.all[0]
  end

  def self.last
    self.all[-1]
  end

  def initialize(params = {})
    self.class.finalize!
    columns = self.class.columns
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      unless columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      setter_method = attr_name.to_s + '='

      self.send("#{attr_name}=", value)

    end
  end

  def attribute_values
    values = []
    self.class.columns.each do |clmn|
        values << self.send(clmn)
    end
    values
  end

  def insert
    how_many_inserts = ["?"] * (self.class.columns.length - 1)
    col_names = self.class.columns.drop(1).join(",")
    query = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{how_many_inserts.join(",")})
    SQL
    DBConnection.execute2(query, *attribute_values.drop(1))
    self.id = DBConnection.last_insert_row_id
  end

  def update
    clmns = self.class.columns.drop(1)
    clmns = clmns.map! {|attr_name| attr_name = "#{attr_name} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values.drop(1), id)
      UPDATE
        #{self.class.table_name}
      SET
        #{clmns}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id === nil
      insert
    else
      update
    end
  end
end
