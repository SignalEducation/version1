require 'rails_helper'

describe 'A student user fills out a cbe', type: :feature do
  let(:user)          { create(:user) }
  let(:body)          { build_stubbed(:exam_body) }
  let(:cbe)           { create(:cbe) }
  let(:cbe_product)   { create(:product, cbe: cbe, product_type: 'cbe') }
  let!(:pages)        { create_list(:cbe_introduction_page, 2, cbe: cbe) }
  let(:exercise)      { create(:exercise, user: user, product: cbe_product) }
  let(:cbe_section)   { create(:cbe_section, cbe: cbe) }

  context 'Walk through a cbe' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)
      allow_any_instance_of(Cbe::IntroductionPage).to receive(:id).and_return(true)
      allow(ExamBody).to receive(:all_active).and_return(ExamBody.where(id: body.id))
    end

    scenario 'Student answers multiple choice question', js: true do
      answers  = attributes_for_list(:cbe_answer, 3)
      question = create(:cbe_question, kind: 'multiple_choice', section: cbe_section, answers_attributes: answers)
      visit exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)
      click_link('Navigator')
      page.execute_script('$(document.elementFromPoint(50, 350)).click();')
      sleep(1)
      click_link('Question 1')
      sleep(1)
      click_button('Yes')
      choose answers[1][:content][:text]
      click_link('Next')
      page.find(:xpath, '//*[@id="cbe-footer"]/footer/nav/ul[2]/li').click
      expect(page).to have_content('Submitted on')
    end

    scenario 'Student answers multiple response question', js: true do
      answers  = attributes_for_list(:cbe_answer, 4)
      question = create(:cbe_question, kind: 'multiple_response', section: cbe_section, answers_attributes: answers)
      visit exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)
      click_link('Navigator')
      page.execute_script('$(document.elementFromPoint(50, 350)).click();')
      click_link('Question 1')
      click_button('Yes')
      check(answers[0][:content][:text], allow_label_click: true)
      check(answers[2][:content][:text], allow_label_click: true)
      click_link('Next')
      page.find(:xpath, '//*[@id="cbe-footer"]/footer/nav/ul[2]/li').click
      expect(page).to have_content('Submitted on')
    end

    scenario 'Student answers fill in the blank question', js: true do
      answers  = attributes_for_list(:cbe_answer, 1)
      question = create(:cbe_question, kind: 'fill_in_the_blank', section: cbe_section, answers_attributes: answers)
      visit exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)
      click_link('Navigator')
      page.execute_script('$(document.elementFromPoint(50, 350)).click();')
      click_link('Question 1')
      click_button('Yes')
      find(:xpath, "//input[@id='1']").set(answers[0][:content][:text])
      click_link('Next')
      page.find(:xpath, '//*[@id="cbe-footer"]/footer/nav/ul[2]/li').click
      expect(page).to have_content('Submitted on')
    end

    scenario 'Student answers open question', js: true do
      answers  = attributes_for_list(:cbe_answer, 1)
      question = create(:cbe_question, kind: 'open', section: cbe_section, answers_attributes: answers)
      visit exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)
      click_link('Navigator')
      page.execute_script('$(document.elementFromPoint(50, 350)).click();')
      click_link('Question 1')
      click_button('Yes')
      iframe = find('iframe')
      within_frame(iframe) do
        editor = page.find_by_id('tinymce')
        editor.native.send_keys answers[0][:content][:text]
      end
      click_link('Next')
      page.find(:xpath, '//*[@id="cbe-footer"]/footer/nav/ul[2]/li').click
      expect(page).to have_content('Submitted on')
    end

    scenario 'Student answers spreadsheet question', js: true do
      answers  = attributes_for_list(:cbe_answer, 1)
      question = create(:cbe_question, kind: 'spreadsheet', section: cbe_section, answers_attributes: answers)
      visit exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)
      click_link('Navigator')
      page.execute_script('$(document.elementFromPoint(50, 350)).click();')
      click_link('Question 1')
      click_button('Yes')
      page.find(:xpath, '//*[@id="pane_0"]/span/section[2]/div/section/div/div/div[1]/div[4]/div[2]/div').set(answers[0][:content][:text])
      click_link('Next')
      page.find(:xpath, '//*[@id="cbe-footer"]/footer/nav/ul[2]/li').click
      expect(page).to have_content('Submitted on')
    end

    scenario 'Student answers drop down list question', js: true do
      answers  = attributes_for_list(:cbe_answer, 5)
      question = create(:cbe_question, kind: 'dropdown_list', section: cbe_section, answers_attributes: answers)
      visit exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)
      click_link('Navigator')
      page.execute_script('$(document.elementFromPoint(50, 350)).click();')
      click_link('Question 1')
      click_button('Yes')
      sleep(1)
      page.execute_script("document.querySelector('#pane_0 > span > section:nth-child(2) > div > section > div').getElementsByTagName('option')[3].selected = 'selected'")
      click_link('Next')
      page.find(:xpath, '//*[@id="cbe-footer"]/footer/nav/ul[2]/li').click
      expect(page).to have_content('Submitted on')
    end
  end
end