# db/seeds/01_truncate.rb
auto_inc_val = 1    # New auto increment start point
tables = [
  "color_statuses",
  "helpee_request_statuses",
  "helper_request_statuses",
  "help_request_statuses",
  "professions",
  "reports",
]
tables.each do |table|
  ActiveRecord::Base.connection.execute(
    "TRUNCATE #{table} RESTART IDENTITY CASCADE"
  )
  ActiveRecord::Base.connection.execute(
    "ALTER SEQUENCE #{table}_id_seq RESTART WITH #{auto_inc_val}"
  )
end
