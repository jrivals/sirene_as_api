class DailyUpdate < ApplicationRecord
  def related_model_name
    related_model
      .name
      .underscore
      .to_sym
  end

  def logger_for_import
    Logger.new logger_file_path.to_s
  end

  def logger_file_path
    Rails.root.join 'log', "daily_update_#{related_model_name}.log"
  end
end
