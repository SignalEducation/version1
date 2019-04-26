# == Schema Information
#
# Table name: faqs
#
#  id              :integer          not null, primary key
#  name            :string
#  name_url        :string
#  active          :boolean          default(TRUE)
#  sorting_order   :integer
#  faq_section_id  :integer
#  question_text   :text
#  answer_text     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pre_answer_text :text
#

require 'rails_helper'

describe Faq do

  subject { FactoryBot.build(:faq) }

  # Constants

  # relationships
  it { should belong_to(:faq_section) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:sorting_order) }
  it { should validate_numericality_of(:sorting_order) }

  it { should validate_presence_of(:faq_section_id) }
  it { should validate_numericality_of(:faq_section_id) }

  it { should validate_presence_of(:question_text) }

  it { should validate_presence_of(:pre_answer_text) }

  it { should validate_presence_of(:answer_text) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Faq).to respond_to(:all_active) }
  it { expect(Faq).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
