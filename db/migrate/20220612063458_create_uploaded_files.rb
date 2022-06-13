class CreateUploadedFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :uploaded_files do |t|
      t.string :file_name
      t.integer :user_id
      t.timestamps
    end
  end
end
