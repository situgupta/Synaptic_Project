class ChangeValueDateTypeIntoInteger < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.execute("ALTER TABLE user_csv_records ALTER COLUMN value TYPE integer USING (value::integer);")
  end
end