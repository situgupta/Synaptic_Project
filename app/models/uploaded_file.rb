class UploadedFile < ApplicationRecord
    has_many :user_csv_records

    def self.add_file(fileName,userId)
        UploadedFile.create!(file_name: fileName,user_id: userId)
    end
end
