# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  product_id         :integer
#  subject_course_id  :integer
#  user_id            :integer
#  stripe_guid        :string
#  stripe_customer_id :string
#  live_mode          :boolean          default(FALSE)
#  current_status     :string
#  coupon_code        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe "Orders", type: :request do
  describe "GET /orders" do
    it "works! (now write some real specs)" do
      get orders_path
      expect(response).to have_http_status(200)
    end
  end
end
