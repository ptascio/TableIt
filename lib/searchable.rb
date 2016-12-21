require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map {|k,v| "#{k} = ?"}.join(" AND ")
    values = params.map {|_,v| v}
    this_object = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
      SQL
    parse_all(this_object)
  end
end

class SQLObject
  extend Searchable
end
