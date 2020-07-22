class ChangeColumnPriceInRequest < ActiveRecord::Migration[6.0]
    def change
        # execute("ALTER TABLE requests ALTER COLUMN price TYPE float USING (price::float)")
    end
end
