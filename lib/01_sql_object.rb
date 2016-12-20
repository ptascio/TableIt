require_relative 'db_connection'
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

  def self.finalize!
    columns.each do |clm|
      define_method(clm) do
         attributes[clm]
      end
       define_method("#{clm}=".to_sym) do |arg|
           attributes[clm] = arg
        end
    end
  end

  def attributes
    @attributes ||= {}
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
        cats.*
      FROM
        "#{self.table_name}"
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
     this_cat = DBConnection.execute(<<-SQL, id)
      SELECT
        "#{self.table_name}".*
      FROM
        "#{self.table_name}"
      WHERE
        "#{self.table_name}".id = ?
     SQL
     return nil if this_cat.empty?
     self.new(this_cat.first)
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      unless columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      setter_method = attr_name.to_s + '='
      #self is instance of Cat model
      self.send(setter_method, value)

      #self.send("favorite_band=", 5)
    end
  end



  # def favorite_band=(band)
  #   attributes[:favorite_band] = band
  # end


  def attribute_values
    values = []
    self.class.columns.each do |clmn|
        values << self.send(clmn)
    end
    values
  end

  def insert
    how_many_inserts = ["?"] * (self.class.columns.length - 1)
    col_name = self.class.columns.drop(1).join(",")
    query = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{col_name})
      VALUES
        (#{how_many_inserts.join(",")})
    SQL
    DBConnection.execute2(query, *attribute_values.drop(1))
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
