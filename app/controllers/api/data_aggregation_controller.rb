module Api
    class DataAggregationController < Api::ApplicationController
        skip_before_action :doorkeeper_authorize!
        def fetch_aggregation_result
            uploaded_file = current_user.uploaded_files.last
            records = UserCsvRecord.where(uploaded_file_id: uploaded_file.id)
            @maxValue = get_max_value(records)
            @median = get_median(records)
            @daywiseTimeSeries = get_time_series_daywise(records)
            @monthwiseTimeSeries = get_time_series_monthwise(records)
            result_json = { maxValue: @maxValue,median: @median,dayWiseTimeSeries: @daywiseTimeSeries,monthWiseTimeSeries: @monthwiseTimeSeries}
            generate_pdf_file(uploaded_file,result_json)
            render(json: { maxValue: @maxValue,median: @median,dayWiseTimeSeries: @daywiseTimeSeries,monthWiseTimeSeries: @monthwiseTimeSeries,message: "Result generated" }, status: 200)
        end

        def get_max_value(records)
            @records = records.pluck(:value)
            maxValue = @records.max()
            return maxValue
        end

        def get_median(records)
            sorted_values = records.pluck(:value).sort.map(&:to_i)
            len = sorted_values.length
            (sorted_values[(len - 1) / 2] + sorted_values[len / 2]) / 2.0
        end

        def get_time_series_daywise(records)
            records = records.pluck(:date,:value)
            series = Hash[records.map {|key, value| [key.to_s, value]}]
            @daywise_series = Prophet.forecast(series)
            return @daywise_series
        end

        def get_time_series_monthwise(records)
            debugger
            records_by_month = records.group_by_month(:date,format: "%b %Y").sum(:value)
            series = Hash[records_by_month.map {|key, value| [key.to_s, value]}]
            @monthwise_series = Prophet.forecast(series)
            return @monthwise_series
        end

        def generate_pdf_file(uploadedFile,data)    
            file_name = "generated_report_"+uploadedFile.id.to_s+".pdf"
            save_path = Rails.root.join('public',file_name)
            Prawn::Document.generate(save_path) do
              text "Max Value: #{data[:maxValue]}"
              text "Median: #{data[:median]}"
              text "Time Series(Day wise): #{data[:dayWiseTimeSeries]}"
              text "Time Series(Month wise): #{data[:monthWiseTimeSeries]}"
            end
            obj = S3_BUCKET.objects[file_name]
            obj.write(file: save_path,acl: :public_read)
            pdf_url = "https://synapticproject.s3.amazonaws.com/#{file_name}"
            File.delete(save_path)
            uploadedFile.update(s3_file_path: pdf_url)
        end

        def share_result
            email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
            isValid = params[:to_email] =~ email_regex
            if params[:to_email].present? && !isValid.nil?
                pdf_url = current_user.uploaded_files.last.s3_file_path
                ResultMailer.result_share_email(params[:to_email],pdf_url).deliver_now
                message = "Report send Successfully"
            else
                message = "Please enter valid email id"
            end
            render(json: { success: message }, status: 200)
        end

    end
end