require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

require 'support/system_setup'

describe 'The student orders process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  include_context 'system_setup'

  let!(:product_1)  { FactoryBot.create(:product) }
  let!(:mock_exam_1)  { FactoryBot.create(:mock_exam, subject_course_id: SubjectCourse.first.id, product_id: product_1.id) }

  before(:each) do
    activate_authlogic
    visit home_path
    stripe_customer = Stripe::Customer.create(email: valid_trial_student.email)
    valid_trial_student.update_attribute(:stripe_customer_id, stripe_customer.id)

    stripe_product = Stripe::Product.create(name: product_1.name, shippable: false, active: product_1.active)
    product_1.update_attribute(:stripe_guid, stripe_product.id)

    sleep(2)
    stripe_sku = Stripe::SKU.create(
        currency: product_1.currency.iso_code,
        price: (product_1.price.to_f * 100).to_i,
        product: product_1.stripe_guid,
        active: product_1.active,
        inventory: {
            type: 'infinite'
        }
    )
    product_1.update_attribute(:stripe_sku_guid, stripe_sku.id)

  end

  describe 'User mock exam and successfully purchases by:' do

    describe 'User purchases a Mock Exam' do
      scenario 'from the media library page', js: true do
        sign_in_via_sign_in_page(valid_trial_student)

        click_link 'Media'
        expect(page).to have_content(I18n.t('views.mock_exams.index.h1'))
        expect(page).to have_content(mock_exam_1.name)
        click_on(mock_exam_1.name)

        #Purchase Product Order
        expect(page).to have_content('Purchase Process')
        expect(page).to have_content(product_1.price)
        enter_credit_card_details('valid')
        check I18n.t('views.general.terms_and_conditions')
        click_on('Purchase Mock Exam')
        sleep(5)
        expect(page).to have_content('Order Complete')
        expect(page).to have_content('Your Mock Exam will be emailed to you shortly. You can also download it below.')
        visit_my_profile
        click_link(I18n.t('views.user_accounts.orders_info.tab_heading'))
        expect(page).to have_content(mock_exam_1.name)
        expect(page).to have_content(product_1.price)
        expect(page).to have_content('Paid')
      end

      scenario 'from the library course page', js: true do
        sign_in_via_sign_in_page(valid_trial_student)


        click_on('Courses')
        click_link(group_1.name)
        click_link(subject_course_1.name)
        expect(page).to have_content subject_course_1.name
        expect(page).to have_content(mock_exam_1.name.upcase)
        parent = page.find('.course-resources li:first-child')
        parent.click


        #Purchase Product Order
        expect(page).to have_content('Purchase Process')
        expect(page).to have_content(product_1.price)
        enter_credit_card_details('valid')
        check I18n.t('views.general.terms_and_conditions')
        click_on('Purchase Mock Exam')
        sleep(5)
        expect(page).to have_content('Order Complete')
        expect(page).to have_content('Your Mock Exam will be emailed to you shortly. You can also download it below.')
        visit_my_profile
        click_link(I18n.t('views.user_accounts.orders_info.tab_heading'))
        expect(page).to have_content(mock_exam_1.name)
        expect(page).to have_content(product_1.price)
        expect(page).to have_content('Paid')

      end
    end

  end


end
