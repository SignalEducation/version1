# frozen_string_literal: true

module UsersCsvHelper
  def preview_csv_user_errors(errors, formatted_errors = [])
    %w[email first_name last_name].each do |key|
      errors[key].each do |error|
        formatted_errors << "#{key.humanize} #{error}" if error.present?
      end
    end

    formatted_errors
  end
end
