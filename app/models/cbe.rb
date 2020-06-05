# frozen_string_literal: true

# == Schema Information
#
# Table name: cbes
#
#  id                :bigint           not null, primary key
#  name              :string
#  title             :string
#  content           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  course_id         :bigint
#  agreement_content :text
#  active            :boolean          default("true"), not null
#  score             :float
#
class Cbe < ApplicationRecord
  # relationships
  belongs_to :course
  has_one :product, dependent: :destroy

  has_many :sections, dependent: :destroy, inverse_of: :cbe,
                      class_name: 'Cbe::Section'
  has_many :introduction_pages, dependent: :destroy, inverse_of: :cbe,
                                class_name: 'Cbe::IntroductionPage'
  has_many :questions, through: :sections, class_name: 'Cbe::Question'
  has_many :resources, inverse_of: :cbe, class_name: 'Cbe::Resource',
                       dependent: :destroy

  # validations
  validates :name, :agreement_content, :course_id, presence: true

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_id) }

  def duplicate
    new_cbe = deep_clone include: [
                            :introduction_pages,
                            :resources,
                            sections: [
                              questions: :answers,
                              scenarios: { questions: :answers }
                            ]
                          ],
                          use_dictionary: true,
                          except: [
                            sections: [
                              scenarios: { questions: :cbe_section_id }
                            ]
                          ], validate: false

    new_cbe.update(name: "#{name} COPY", active: false)
  end
end
