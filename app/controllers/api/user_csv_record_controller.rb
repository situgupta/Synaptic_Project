module Api
    class UserCsvRecordController < Api::ApplicationController
        skip_before_action :doorkeeper_authorize!

        def import
            uploaded_file = UploadedFile.add_file(params[:file].original_filename.gsub(/\s+/, ""),current_user.id)
            UserCsvRecord.import(params[:file],current_user,uploaded_file.id)
            render(json: { success: "File Uploaded Successfully" }, status: 200)
        end

        def export
            uploaded_file = current_user.uploaded_files.last
            @csv_records = UserCsvRecord.where(uploaded_file_id: uploaded_file.id)
            csv_file_name = uploaded_file.file_name.strip
            save_path = Rails.root.join('public',csv_file_name)
            File.open(save_path, 'wb') do |file|
                file << @csv_records.to_csv
            end 
            csv_file = File.join('public',csv_file_name)
            obj = S3_BUCKET.objects[csv_file_name]
            obj.write(file: csv_file,acl: :public_read)
            File.delete(save_path)
            csv_url = "https://synapticproject.s3.amazonaws.com/#{csv_file_name}"
            render(json: { url: csv_url,message: "File Generated" }, status: 200)
        end

        
    end
end