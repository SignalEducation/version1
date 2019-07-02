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
#  product_type      :integer          default(0)
#

require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user, user_group_id: stripe_management_user_group.id) }

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:product_1) { FactoryBot.create(:product, currency_id: gbp.id) }
  let!(:product_2) { FactoryBot.create(:product, currency_id: gbp.id) }
  let!(:mock_exam) { FactoryBot.create(:mock_exam, name: 'Mock 001') }
  let!(:order) { FactoryBot.create(:order, product_id: product_1.id, stripe_order_payment_data: { currency: gbp.iso_code }) }
  let!(:valid_params) { FactoryBot.attributes_for(:product, active: false, currency_id: gbp.id, mock_exam_id: mock_exam.id, correction_pack_count: 1) }

  context 'Logged in as a stripe_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('products', 2)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('product')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with product_1' do
        get :edit, params: { id: product_1.id }
        expect_edit_success_with_model('product', product_1.id)
      end

      # optional
      it 'should respond OK with product_2' do
        get :edit, params: { id: product_2.id }
        expect_edit_success_with_model('product', product_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { product: valid_params }
        expect_create_success_with_model('product', products_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { product: {valid_params.keys.first => ''} }
        expect_create_error_with_model('product')
      end
    end

    describe "POST 'reorder'" do
      context 'keep order' do
        before do
          post :reorder, params: { array_of_ids: Product.all.pluck(:id) }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
          expect(response.body).to eq('{}')
        end

        it 'return a same product list' do
          expect(Product.all.pluck(:sorting_order)).to eq([1, 2])
        end
      end

      context 'reverse order' do
        before do
          post :reorder, params: { array_of_ids: Product.all.pluck(:id).reverse }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
          expect(response.body).to eq('{}')
        end

        it 'return a reorder product list' do
          expect(Product.all.order(:id).pluck(:sorting_order)).to eq([2, 1])
        end
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for product_1' do
        put :update, params: { id: product_1.id, product: valid_params }
        expect_update_success_with_model('product', products_url)
      end

      # optional
      it 'should respond OK to valid params for product_2' do
        put :update, params: { id: product_2.id, product: valid_params }
        expect_update_success_with_model('product', products_url)
        expect(assigns(:product).id).to eq(product_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: product_1.id, product: {valid_params.keys.first => ''} }
        expect_update_error_with_model('product')
        expect(assigns(:product).id).to eq(product_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, params: { id: product_1.id }
        expect_delete_error_with_model('product', products_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: product_2.id }
        expect_delete_success_with_model('product', products_url)
      end
    end

  end

end
