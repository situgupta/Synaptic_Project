class AddColumnUploadedFileIdIntoUserCsvRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :user_csv_records, :uploaded_file_id, :integer,:references => "uploaded_files"
  end
end