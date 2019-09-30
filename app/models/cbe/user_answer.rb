# frozen_string_literal: true

class Cbe::UserAnswer < ApplicationRecord
  # relationships
  belongs_to :user_log, class_name: 'Cbe::UserLog', foreign_key: 'cbe_user_log_id',
                        inverse_of: :answers, optional: true

  # validations
  validates :content, presence: true
end
