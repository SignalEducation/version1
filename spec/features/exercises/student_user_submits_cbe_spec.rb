# TODO: Redo this spec for CBE (Rohan)
# require 'rails_helper'

# describe 'A student user fills out a cbe', type: :feature do
#   let(:user)                        { create(:user) }
#   let(:cbe)                         { create(:cbe) }
#   let!(:pages)                      { create_list(:cbe_introduction_page, 2, cbe: cbe) }
#   let(:cbe_section)                 { create(:cbe_section, cbe: cbe) }

#   let(:multiple_choice_answers)     { attributes_for_list(:cbe_answer, 3) }
#   let!(:multiple_choice)            { create(:cbe_question, kind: 'multiple_choice', sorting_order: 1, section: cbe_section, answers_attributes: multiple_choice_answers) }

#   let(:multiple_response_answers)   { attributes_for_list(:cbe_answer, 4) }
#   let!(:multiple_response_question) { create(:cbe_question, kind: 'multiple_response', sorting_order: 2, section: cbe_section, answers_attributes: multiple_response_answers) }

#   let(:fill_in_the_blank_answers)   { attributes_for_list(:cbe_answer, 1) }
#   let!(:fill_in_the_blank_question) { create(:cbe_question, kind: 'fill_in_the_blank', sorting_order: 3, section: cbe_section, answers_attributes: fill_in_the_blank_answers) }

#   let(:open_answers)                { attributes_for_list(:cbe_answer, 1) }
#   let!(:open_question)              { create(:cbe_question, kind: 'open', sorting_order: 4, section: cbe_section, answers_attributes: open_answers) }

#   let(:spreadsheet_answers)         { attributes_for_list(:cbe_answer, 1) }
#   let!(:spreadsheet_question)       { create(:cbe_question, kind: 'spreadsheet', sorting_order: 5, section: cbe_section, answers_attributes: spreadsheet_answers) }

#   let(:dropdown_list_answers)       { attributes_for_list(:cbe_answer, 5) }
#   let!(:dropdown_list_question)     { create(:cbe_question, kind: 'dropdown_list', sorting_order: 6, section: cbe_section, answers_attributes: dropdown_list_answers) }

#   let(:cbe_product)   { create(:product, cbe: cbe, product_type: 'cbe') }
#   let(:exercise)      { create(:exercise, user: user, product: cbe_product) }

#   context 'Walk through a cbe' do
#     before do
#       allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
#       allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
#       allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)
#       allow_any_instance_of(Cbe::IntroductionPage).to receive(:id).and_return(true)
#     end
#     scenario 'Student answersall cbe questions and submit it', js: true do
#       # start a cbe and go to the first
#       visit exercise_cbes_path(id: exercise.product.cbe.id, exercise_id: exercise.id)

#       click_link('Navigator')
#       sleep(1)
#       page.execute_script('$(document.elementFromPoint(50, 350)).click();')
#       sleep(1)
#       click_link('Question 1')
#       sleep(3)
#       click_button('Yes')

#       # multiple_choice_answers question
#       sleep(1)
#       choose multiple_choice_answers[1][:content][:text]
#       click_link('Next')

#       # multiple_response question
#       sleep(1)
#       check(multiple_response_answers[0][:content][:text], allow_label_click: true)
#       check(multiple_response_answers[2][:content][:text], allow_label_click: true)
#       click_link('Next')

#       # fill_in_the_blank question
#       sleep(1)
#       within('.answers') do
#         find(:xpath, "//input").set(fill_in_the_blank_answers[0][:content][:text])
#       end
#       click_link('Next')

#       # open question
#       sleep(3)
#       iframe = find('iframe')
#       within_frame(iframe) do
#         editor = page.find_by_id('tinymce')
#         editor.native.send_keys open_answers[0][:content][:text]
#       end
#       click_link('Next')

#       # spreadsheet question
#       sleep(1)
#       page.find(:xpath, '//*[@id="pane_0"]/span/section[2]/div/section/div/div/div[1]/div[4]/div[2]/div').set(spreadsheet_answers[0][:content][:text])
#       click_link('Next')

#       # dropdown_list question
#       sleep(1)
#       page.execute_script("document.querySelector('#pane_0 > span > section:nth-child(2) > div > section > div').getElementsByTagName('option')[3].selected = 'selected'")
#       click_link('Next')

#       # Submitted page
#       sleep(1)
#       page.find(:xpath, '//*[@id="cbe-footer"]/footer/nav/ul[2]/li').click
#       sleep(2)
#       expect(page).to have_content('Submitted on')
#     end
#   end
# end
