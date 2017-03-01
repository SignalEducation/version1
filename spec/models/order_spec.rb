# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  current_status            :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#

require 'rails_helper'

describe Order do

  # attr-accessible
  black_list = %w(id created_at updated_at coupon_code)
  Order.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:product) }
  it { should belong_to(:subject_course) }
  it { should belong_to(:mock_exam) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:product_id) }
  it { should validate_numericality_of(:product_id) }

  it { should_not validate_presence_of(:subject_course_id) }

  it { should validate_presence_of(:terms_and_conditions) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:stripe_guid) }

  it { should validate_presence_of(:stripe_customer_id) }

  it { should validate_presence_of(:current_status) }

  it { should_not validate_presence_of(:coupon_code) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Order).to respond_to(:all_in_order) }
  it { expect(Order).to respond_to(:all_for_course) }
  it { expect(Order).to respond_to(:all_for_product) }
  it { expect(Order).to respond_to(:all_for_user) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  it { should respond_to(:stripe_token) }


end
