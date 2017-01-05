require relative 'lib/sql_object.rb'

class Guitar < SQLObject
  belongs_to(
    :musician,
    class_name: "Musician",
    foreign_key: musician_id,
    primary_key: id
  )

  has_one_through(:company, :musician, :company)
end

class Musician < SQLObject
  has_many(
    :guitars,
    class_name: "Guitar",
    foreign_key: musician_id,
    primary_key: id
  )
  belongs_to(
    :company,
    class_name: "Company",
    foreign_key: company_id,
    primary_key: id
  )
end

class Company < SQLObject
  has_many(
    :musicians,
    class_name: "Musician",
    foreign_key: company_id,
    primary_key: id
  )
end

puts "initializing Database"
p DBConnection.reset
