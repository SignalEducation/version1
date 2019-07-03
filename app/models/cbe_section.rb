class CbeSection < ApplicationRecord

  belongs_to :cbe, dependent: :destroy
  has_many :cbe_questions, dependent: :destroy

  validates :name, :scenario_label, :scenario_description, :cbe, presence: true

end