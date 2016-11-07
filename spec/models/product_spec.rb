# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  mock_exam_id      :integer
#  stripe_guid       :string
#  live_mode         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  active            :boolean          default(FALSE)
#  currency_id       :integer
#  price             :decimal(, )
#  stripe_sku_guid   :string
#

require 'rails_helper'

describe Product do

  # attr-accessible
  black_list = %w(id created_at updated_at mock_exam_id)
  Product.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(Product.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:subject_course) }
  it { should belong_to(:currency) }
  it { should have_many(:orders) }
  xit { should belong_to(:mock_exam) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:subject_course_id) }
  it { should validate_numericality_of(:subject_course_id) }

  it { should_not validate_presence_of(:mock_exam_id) }
  it { should_not validate_numericality_of(:mock_exam_id) }

  it { should_not validate_presence_of(:stripe_guid) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_on_stripe).after(:create) }
  it { should callback(:update_on_stripe).after(:update) }

  # scopes
  it { expect(Product).to respond_to(:all_in_order) }
  it { expect(Product).to respond_to(:all_active) }
  it { expect(Product).to respond_to(:in_currency) }

  # class methods

  # instance methods
  it { should respond_to(:create_on_stripe) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:update_on_stripe) }


end
