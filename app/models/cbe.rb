class Cbe < ApplicationRecord
  has_many :cbe_sections
  has_many :cbe_questions
  has_many :cbe_introduction_pages
  has_one :cbe_agreement


end
