# frozen_string_literal: true

class JwtBlockedToken < ApplicationRecord
  validates :token, presence: true
end
