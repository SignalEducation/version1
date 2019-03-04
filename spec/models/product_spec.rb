# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  name              :string
#  mock_exam_id      :integer
#  stripe_guid       :string
#  live_mode         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  active            :boolean          default(FALSE)
#  currency_id       :integer
#  price             :decimal(, )
#  stripe_sku_guid   :string
#  subject_course_id :integer
#  sorting_order     :integer
#  product_type      :integer          default("mock_exam")
#

require 'rails_helper'

describe Product do
  # relationships
  it { should belong_to(:currency) }
  it { should belong_to(:mock_exam) }
  it { should have_many(:orders) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:mock_exam_id) }
  it { should validate_numericality_of(:mock_exam_id) }

  it { should validate_presence_of(:currency_id) }

  it { should validate_presence_of(:price) }

  it { should validate_presence_of(:stripe_guid).on(:update) }
  it { should validate_presence_of(:stripe_sku_guid).on(:update) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_on_stripe).after(:create) }
  it { should callback(:update_on_stripe).after(:update) }

  # scopes
  it { expect(Product).to respond_to(:all_in_order) }
  it { expect(Product).to respond_to(:all_active) }
  it { expect(Product).to respond_to(:in_currency) }

  # class methods
  it { expect(Product).to respond_to(:search) }

  # instance methods
  it { should respond_to(:create_on_stripe) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:update_on_stripe) }


end
