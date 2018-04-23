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

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Faq.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(Faq.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:faq_section) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:faq_section_id) }
  it { should validate_numericality_of(:faq_section_id) }

  it { should validate_presence_of(:question_text) }

  it { should validate_presence_of(:answer_text) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Faq).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
