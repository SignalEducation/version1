# Some methods that are auto-loaded by rails_helper.rb into every RSpec test.

######
## controllers
##
def expect_bounce_as_not_signed_in
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to eq(I18n.t('controllers.application.logged_in_required.flash_error'))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(sign_in_url)
end

def expect_bounce_as_signed_in
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to eq(I18n.t('controllers.application.logged_out_required.flash_error'))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(root_url)
end

def expect_bounce_as_not_allowed
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(root_url)
end

def expect_index_success_with_model(model_name, record_count, assign_name = nil)
  assign_name = model_name if assign_name.nil?
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to be_nil
  expect(response.status).to eq(200)
  expect(response).to render_template(:index)
  expect(assigns(assign_name.to_sym).first.class.name).to eq(model_name.classify)
  expect(assigns(assign_name.to_sym).count).to eq(record_count)
end

def expect_show_success_with_model(model_name, expected_id=nil)
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to be_nil
  expect(response.status).to eq(200)
  expect(response).to render_template(:show)
  expect(assigns(model_name.to_sym).class.name).to eq(model_name.classify)
  expect(assigns(model_name.to_sym).id).to eq(expected_id) if expected_id
end

def expect_new_success_with_model(model_name, assign_name = nil)
  assign_name = model_name if assign_name.nil?
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to be_nil
  expect(response.status).to eq(200)
  expect(response).to render_template(:new)
  expect(assigns(assign_name.to_sym).class.name).to eq(model_name.classify)
end

def expect_edit_success_with_model(model_name, expected_id=nil, assign_name = nil)
  assign_name = model_name if assign_name.nil?
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to be_nil
  expect(response.status).to eq(200)
  expect(response).to render_template(:edit)
  expect(assigns(assign_name.to_sym).class.name).to eq(model_name.classify)
  expect(assigns(assign_name.to_sym).id).to eq(expected_id) if expected_id
end

def expect_create_success_with_model(model_name, destination, special_flash=nil, assign_name = nil)
  assign_name = model_name if assign_name.nil?
  expect(flash[:error]).to be_nil
  expect(flash[:success]).to eq(special_flash || I18n.t("controllers.#{assign_name.pluralize}.create.flash.success"))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(destination)
  expect(assigns(assign_name.to_sym).class.name).to eq(model_name.classify)
end

def expect_create_error_with_model(model_name, assign_name = nil)
  assign_name = model_name if assign_name.nil?
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to be_nil
  expect(response.status).to eq(200)
  expect(response).to render_template(:new)
  expect(assigns(assign_name.to_sym).class.name).to eq(model_name.classify)
end

def expect_update_success_with_model(model_name, destination, assign_name = nil)
  assign_name = model_name if assign_name.nil?
  expect(flash[:error]).to be_nil
  expect(flash[:success]).to eq(I18n.t("controllers.#{assign_name.pluralize}.update.flash.success"))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(destination)
  expect(assigns(assign_name.to_sym).class.name).to eq(model_name.classify)
end

def expect_update_error_with_model(model_name, assign_name = nil)
  assign_name = model_name if assign_name.nil?
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to be_nil
  expect(response.status).to eq(200)
  expect(response).to render_template(:edit)
  expect(assigns(assign_name.to_sym).class.name).to eq(model_name.classify)
end

def expect_reorder_success
  expect(response.status).to eq(200)
end

def expect_delete_success_with_model(model_name, destination)
  expect(flash[:error]).to be_nil
  expect(flash[:success]).to eq(I18n.t("controllers.#{model_name.pluralize}.destroy.flash.success"))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(destination)
  expect(assigns(model_name.to_sym).class.name).to eq(model_name.classify)
end

def expect_archive_success_with_model(model_name, record_id, destination)
  expect(flash[:error]).to be_nil
  expect(flash[:success]).to eq(I18n.t("controllers.#{model_name.pluralize}.destroy.flash.success"))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(destination)
  expect(assigns(model_name.to_sym).class.name).to eq(model_name.classify)
  expect(assigns(model_name.to_sym).destroyed_at).to_not be_nil
end

def expect_delete_error_with_model(model_name, destination)
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to eq(I18n.t("controllers.#{model_name.pluralize}.destroy.flash.error"))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(destination)
  expect(assigns(model_name.to_sym).class.name).to eq(model_name.classify)
end

def expect_change_password_success_with_model(destination)
  expect(flash[:error]).to be_nil
  expect(flash[:success]).to eq(I18n.t('controllers.users.change_password.flash.success'))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(destination)
  expect(assigns(:user).class.name).to eq('User')
end

def expect_change_password_error_with_model(destination)
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to eq(I18n.t('controllers.users.change_password.flash.error'))
  expect(response.status).to eq(302)
  expect(response).to redirect_to(destination)
  expect(assigns(:user).class.name).to eq('User')
end

def expect_error_bounce(destination_url)
  expect(flash[:error]).to_not be_nil
  expect(flash[:success]).to be_nil
  expect(response).to redirect_to(destination_url)
end

def expect_import_csv_success_with_model(model_name, record_count)
  expect(flash[:success]).to be_nil
  expect(flash[:error]).to be_nil
  expect(response.status).to eq(200)
  expect(response).to render_template(:import_csv)
  expect(assigns(model_name.to_sym).first.class.name).to eq(model_name.classify)
  expect(assigns(model_name.to_sym).count).to eq(record_count)
end

######
## mailers
##
def expect_delivery_to_from_and_subject_success(recipient_email, mailer_name, method_name)
  expect(ActionMailer::Base.deliveries.count).to eq(1)
  expect(ActionMailer::Base.deliveries.first.to.first).to eq(recipient_email)
  expect(ActionMailer::Base.deliveries.first.subject).to eq(I18n.t("mailers.#{mailer_name}.#{method_name}.subject_line"))
  expect(ActionMailer::Base.deliveries.first.from.first).to eq(ENV['learnsignal_v3_server_email_address'])
end
