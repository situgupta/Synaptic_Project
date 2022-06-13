class AddCloumnS3FilePathIntoUploadedFiles < ActiveRecord::Migration[6.1]
  def change
    add_column :uploaded_files, :s3_file_path, :string
  end
end