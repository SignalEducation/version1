# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_user_responses
#
#  id                     :bigint           not null, primary key
#  content                :json
#  educator_comment       :text
#  score                  :float            default("0.0")
#  correct                :boolean          default("false")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  cbe_user_log_id        :bigint
#  cbe_response_option_id :bigint
#
class Cbe
  class UserResponse < ApplicationRecord
    # relationships
    belongs_to :user_log, class_name: 'Cbe::UserLog', foreign_key: 'cbe_user_log_id',
                          inverse_of: :responses
    belongs_to :cbe_response_option, class_name: 'Cbe::ResponseOption',
                                     foreign_key: 'cbe_response_option_id',
                                     inverse_of: :user_responses

    # scopes
    scope :by_scenario, ->(sc_id) { includes(cbe_response_option: :scenario).where(cbe_scenarios: { id: sc_id }) }
  end
end
