class CbeQuestion < ApplicationRecord
  belongs_to :cbe_question_grouping, dependent: :destroy
  has_one :cbe_question_type, dependent: :destroy

end
