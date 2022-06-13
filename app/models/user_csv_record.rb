class UserCsvRecord < ApplicationRecord
    belongs_to :user
    belongs_to :uploaded_file

    def self.import(file,current_user,uploadedFileId)
        csv_items = Hash.new
        index=0
        keys=[]
        csv_data_list=[]
        csv_data=Hash.new
        CSV.foreach(file.path) do |row|
            if index == 0
                keys=row
                index=index+1
            else     
                keys.each_with_index.map { |x,i|
                    if !row[i].nil? && !row[i].blank? 
                        csv_data["#{x.strip}"] = "#{row[i].strip}"
                        csv_data["uploaded_file_id"] = uploadedFileId
                    else
                        csv_data["#{x.strip}"] = nil
                    end        
                    if (keys.length - 1) == i
                        csv_data_list.push(csv_data)
                        csv_data=Hash.new
                    end
                }            
            end                                    
        end  
        csv_data_list.each do |data| 
            begin
                user_record = current_user.user_csv_records.new
                if (!data["uploaded_file_id"].nil? && !data["uploaded_file_id"].blank?)
                    user_record.date = data["date"]
                    user_record.value = data["value"]
                    user_record.domain_name = data["domain_name"]
                    user_record.uploaded_file_id = data["uploaded_file_id"]
                    user_record.save!
                end
            rescue Exception => e                                        
                logger.info "error details: #{e}"            
            end    
        end
        # CSV.foreach(file.path, headers: true)do |row|
        #     current_user.user_csv_records.find_or_create_by row.to_hash
        # end
    end 

    def self.to_csv
        attributes = %w{date value domain_name}
        CSV.generate(headers: true) do |csv|
            csv<< attributes
            all.each do |row|
                p"#{row}"
                csv << attributes.map{|attr| row.send(attr)}
            end
        end
    end
end
