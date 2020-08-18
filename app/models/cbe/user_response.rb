# frozen_string_literal: true

class Cbe
  class UserResponse < ApplicationRecord
    # relationships
    belongs_to :user_log, class_name: 'Cbe::UserLog', foreign_key: 'cbe_user_log_id',
                          inverse_of: :responses
    belongs_to :cbe_response_option, class_name: 'Cbe::ResponseOption',
                                     foreign_key: 'cbe_response_option_id',
                                     inverse_of: :user_responses
    has_one :scenario, through: :cbe_response_option
  end
end
