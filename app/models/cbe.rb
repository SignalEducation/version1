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

  has_many :introduction_pages, dependent: :destroy, inverse_of: :cbe,
                                class_name: 'Cbe::IntroductionPage'
  has_many :sections, dependent: :destroy, inverse_of: :cbe,
                      class_name: 'Cbe::Section'
  has_many :scenarios, through: :sections, class_name: 'Cbe::Scenario'
  has_many :questions, through: :sections, class_name: 'Cbe::Question'
  has_many :exhibits, through: :scenarios, class_name: 'Cbe::Exhibit'
  has_many :requirements, through: :scenarios, class_name: 'Cbe::Requirement'
  has_many :response_options, through: :scenarios, class_name: 'Cbe::ResponseOption'
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

    ActiveRecord::Base.transaction do
      new_cbe.update(name: "#{name} COPY", active: false) && update_all_files(new_cbe)
    end
  end

  def update_all_files(new_cbe)
    new_cbe.resources.each do |resource|
      old_resource = resources.find_by(name: resource.name,
                                       sorting_order: resource.sorting_order,
                                       document_file_name: resource.document_file_name)
      resource.document = old_resource.document
      resource.save
    end
  end

  def exhibit_scenario?
    sections.map(&:exhibits_scenario?).any?
  end

  def total_score
    exhibit_scenario? ? requirements.map(&:score).sum : questions.map(&:score).sum
  end
end
