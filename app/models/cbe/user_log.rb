# frozen_string_literal: true

class Cbe::UserLog < ApplicationRecord
  # relationships
  belongs_to :cbe
  belongs_to :user

  has_many :answers, class_name: 'Cbe::UserAnswer', foreign_key: 'cbe_user_log_id',
                     inverse_of: :user_log, dependent: :destroy

  accepts_nested_attributes_for :answers

  # validations
  validates :cbe_id, presence: true

  # enums
  enum status: { started: 0, paused: 1, finished: 3 }
end
