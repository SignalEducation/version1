# frozen_string_literal: true

# == Schema Information
#
# Table name: jwt_blocked_tokens
#
#  id         :bigint           not null, primary key
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class JwtBlockedToken < ApplicationRecord
  validates :token, presence: true
end
