class ChangeTypeStringToFloatInLatitudeLongitude < ActiveRecord::Migration[6.0]
  def change
      execute("ALTER TABLE chats ALTER COLUMN latitude TYPE float USING (latitude::float)")
      execute("ALTER TABLE chats ALTER COLUMN longitude TYPE float USING (longitude::float)")
      execute("ALTER TABLE help_requests ALTER COLUMN latitude TYPE float USING (latitude::float)")
      execute("ALTER TABLE help_requests ALTER COLUMN longitude TYPE float USING (longitude::float)")
      execute("ALTER TABLE offer_requests ALTER COLUMN latitude TYPE float USING (latitude::float)")
      execute("ALTER TABLE offer_requests ALTER COLUMN longitude TYPE float USING (longitude::float)")
      execute("ALTER TABLE users ALTER COLUMN latitude TYPE float USING (latitude::float)")
      execute("ALTER TABLE users ALTER COLUMN longitude TYPE float USING (longitude::float)")
  end
end
