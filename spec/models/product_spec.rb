# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  mock_exam_id          :integer
#  stripe_guid           :string
#  live_mode             :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  active                :boolean          default(FALSE)
#  currency_id           :integer
#  price                 :decimal(, )
#  stripe_sku_guid       :string
#  subject_course_id     :integer
#  sorting_order         :integer
#  product_type          :integer          default("mock_exam")
#  correction_pack_count :integer
#

require 'rails_helper'

describe Product do
  let(:order_product)    { create(:product, :with_order) }
  let(:active_product)   { create(:product) }
  let(:inactive_product) { create(:product, :inactive) }

  # relationships
  it { should belong_to(:currency) }
  it { should belong_to(:mock_exam) }
  it { should have_many(:exercises) }
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
  it { should callback(:create_on_stripe).after(:create) }
  it { should callback(:update_on_stripe).after(:update) }

  # scopes
  it { expect(Product).to respond_to(:all_in_order) }
  it { expect(Product).to respond_to(:all_active) }
  it { expect(Product).to respond_to(:in_currency) }

  # class methods
  it { expect(Product).to respond_to(:search) }
  it { expect(Product).to respond_to(:filter_by_state) }

  describe 'Methods' do
    before do
      @first_term  = active_product.name
      @second_term = inactive_product.name
    end

    context '#destroyable?' do
      it 'without orders' do
        expect(active_product.destroyable?).to be_truthy
      end

      it 'without orders' do
        expect(order_product.destroyable?).to be_falsey
      end
    end

    context '.search' do
      it 'complete term' do
        result = Product.search(@first_term)

        expect(result).to     include(active_product)
        expect(result).not_to include(inactive_product)
      end

      it 'partial term' do
        result = Product.search(@second_term[0, 4])

        expect(result).to include(active_product)
        expect(result).to include(inactive_product)
      end
    end

    context '.filter_by_state' do
      it 'default' do
        result = Product.filter_by_state(nil)

        expect(result).to     include(active_product)
        expect(result).not_to include(inactive_product)
      end

      it 'active' do
        result = Product.filter_by_state('Active')

        expect(result).to     include(active_product)
        expect(result).not_to include(inactive_product)
      end

      it 'inactive' do
        result = Product.filter_by_state('Inactive')

        expect(result).not_to include(active_product)
        expect(result).to     include(inactive_product)
      end

      it 'all' do
        result = Product.filter_by_state('All')

        expect(result).to include(active_product)
        expect(result).to include(inactive_product)
      end
    end
  end
end
