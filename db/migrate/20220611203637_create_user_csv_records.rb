class CreateUserCsvRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :user_csv_records do |t|
      t.date :date 
      t.string :value
      t.string :domain_name
      t.references :user, null: false, index: true, foreign_key: true
      t.timestamps
    end
  end
end