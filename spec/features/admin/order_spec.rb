require 'rails_helper'

RSpec.feature 'Admin::Orders', type: :feature do
  let(:user_1)   { create(:user) }
  let(:user_2)   { create(:user) }
  let(:body)   { build_stubbed(:exam_body)}
  let!(:order) { create(:order, user: user_1, state: :completed) }
  let!(:cancelled_order) { create(:order, user: user_2, state: :cancelled) }


  context 'Handle orders from management console' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)
      allow(ExamBody).to receive(:all_active).and_return(ExamBody.where(id: body.id))
    end

    scenario 'Cancel student order', js: true do
      visit user_path(id: user_1.id)
      expect(page).to have_content("#{user_1.email}")
      click_link('Purchases')
      expect(page).to have_content('Invoices')
      within('.admin-product-orders') do
        first(:link, I18n.t('views.general.view')).click
      end
      expect(page).to have_content("Order ID: #{order.id}")
      find('#admin-cancel-order').click
      expect(page).to have_content("Cancel Order of\n#{order.product.product_type}")
      fill_in 'order_cancellation_note', with: 'Student introduced cancellation reason'
      page.accept_alert "Are you sure you want to permanently delete the order of #{order.product.product_type} for #{user_1.full_name}?" do
        find('#confirm_cancellation_button').click
      end
      expect(page).to have_content('cancelled')
      expect(page).to have_content('Reactivate Order')
    end

    scenario 'Reactivate student order', js: true do
      visit user_path(id: user_2.id)
      expect(page).to have_content("#{user_2.email}")
      click_link('Purchases')
      expect(page).to have_content('Invoices')
      within('.admin-product-orders') do
        first(:link, I18n.t('views.general.view')).click
      end
      expect(page).to have_content("Order ID: #{cancelled_order.id}")
      page.accept_alert 'Are you sure you want to reactivate this order?' do
        find('#admin-reactivate-order').click
      end
      expect(page).to have_content('Cancel Order')
    end
  end
end
