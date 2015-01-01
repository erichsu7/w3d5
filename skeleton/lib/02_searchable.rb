require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_conditions = params.map { |key, value| "#{key} = ?" }.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_conditions}
    SQL

    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
