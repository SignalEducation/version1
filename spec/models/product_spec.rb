# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  course_id     :integer
#  mock_exam_id          :integer
#  stripe_guid           :string
#  live_mode             :boolean          default("false")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  active                :boolean          default("false")
#  currency_id           :integer
#  price                 :decimal(, )
#  stripe_sku_guid       :string
#  sorting_order         :integer
#  product_type          :integer          default("0")
#  correction_pack_count :integer
#  cbe_id                :bigint
#  group_id              :integer
#  payment_heading       :string
#  payment_subheading    :string
#  payment_description   :text
#

require 'rails_helper'

describe Product do
  let(:order_product)           { create(:product, :with_order) }
  let(:active_product)          { create(:product) }
  let(:inactive_product)        { create(:product, :inactive) }
  let(:cbe)                     { create(:cbe) }
  let(:cbe_product)             { create(:product, cbe: cbe, product_type: 'cbe') }
  let(:correction_pack_product) { create(:product, cbe: cbe, product_type: 'correction_pack', correction_pack_count: 3) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:mock_exam_id) }
    it { should respond_to(:stripe_guid) }
    it { should respond_to(:live_mode) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:active) }
    it { should respond_to(:currency_id) }
    it { should respond_to(:price) }
    it { should respond_to(:stripe_sku_guid) }
    it { should respond_to(:course_id) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:product_type) }
    it { should respond_to(:correction_pack_count) }
    it { should respond_to(:cbe_id) }
    it { should respond_to(:group_id) }
    it { should respond_to(:payment_heading) }
    it { should respond_to(:payment_subheading) }
    it { should respond_to(:payment_description) }
  end

  # relationships
  it { should belong_to(:currency) }
  it { should belong_to(:mock_exam) }
  it { should have_many(:exercises) }
  it { should have_many(:orders) }

  # validation
  it { should validate_presence_of(:currency_id) }

  it { should validate_presence_of(:price) }

  it { should validate_presence_of(:stripe_guid).on(:update) }
  it { should validate_presence_of(:stripe_sku_guid).on(:update) }

  # scopes
  it { expect(Product).to respond_to(:all_in_order) }
  it { expect(Product).to respond_to(:all_active) }
  it { expect(Product).to respond_to(:in_currency) }
  it { expect(Product).to respond_to(:cbes) }
  it { expect(Product).to respond_to(:mock_exams) }

  # class methods
  it { expect(Product).to respond_to(:search) }
  it { expect(Product).to respond_to(:filter_by_state) }

  describe 'callbacks' do
    it 'calls create_on_stripe after a record is created' do
      expect_any_instance_of(Product).to receive(:create_on_stripe)

      create(:product)
    end

    it 'calls update_on_stripe after a record is updated' do
      product = create(:product)
      expect_any_instance_of(Product).to receive(:update_on_stripe)

      product.update(name: 'New Name')
    end
  end

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

    describe '.name_by_type' do
      context 'for CBE Products' do
        it 'returns the name of the CBE' do
          expect(cbe_product.name_by_type).to eq(cbe_product.cbe.name)
        end
      end

      context 'for non-CBE Procucts' do
        let(:product_without_mock) { build_stubbed(:product, mock_exam: nil) }

        it 'returns the name of the MockExam (if it exists as an association)' do
          expect(correction_pack_product.name_by_type).to eq(correction_pack_product.mock_exam.name)
        end

        it 'returns the name of the Product (if there is no MockExam)' do
          expect(product_without_mock.name_by_type).to eq(product_without_mock.name)
        end
      end
    end
  end
end
