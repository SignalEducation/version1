# frozen_string_literal: true

# Model responsible to external apps management.
#
# ==== Examples
#
# ExternalApp.create(name: 'Learnsignal Front End', slug: 'learnsignal-frontend')
# => <ExternalApp id: 1, name: "Learnsignal Front End", slug: "learnsignal-frontend", api_key: "some_spi", status: "active">
# playon_subscriber.active? #=> true
# playon_subscriber.inactive! #=> true

class ExternalApp < ApplicationRecord
  enum status: { inactive: 0, active: 1 }

  before_validation :generate_api_key

  validates :name, :slug, :api_key, :status, presence: true
  validates :name, :slug, :api_key, uniqueness: true
  validates :slug, format: { without: /\s/, message: 'should not have whitespaces.' }

  def generate_api_key
    return if api_key.present?

    self.api_key = SecureRandom.hex
  end
end
