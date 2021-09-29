# frozen_string_literal: true

json.id                              user.id
json.name                            user.name
json.first_name                      user.first_name
json.last_name                       user.last_name
json.email                           user.email
json.active                          user.active
json.address                         user.address
json.user_group                      user.user_group.name
json.guid                            user.guid
json.address                         user.address
json.valid_subscription              user.valid_subscription?
json.email_verification_code         user.email_verification_code
json.email_verified_at               user.email_verified_at
json.email_verified                  user.email_verified
json.verify_remain_days              user.verify_remain_days
json.verify_email_message            verify_email_message(remain_days)
json.show_verify_email_message       user.show_verify_email_message?
json.free_trial                      user.free_trial
json.terms_and_conditions            user.terms_and_conditions
json.date_of_birth                   user.date_of_birth
json.description                     user.description
json.analytics_guid                  user.analytics_guid
json.student_number                  user.student_number
json.unsubscribed_from_emails        user.unsubscribed_from_emails
json.communication_approval          user.communication_approval
json.communication_approval_datetime user.communication_approval_datetime
json.preferred_exam_body_id          user.preferred_exam_body_id
json.currency_id                     user.currency_id
json.video_player                    user.video_player
json.profile_image_file_name         user.profile_image_file_name
json.profile_image_content_type      user.profile_image_content_type
json.profile_image_file_size         user.profile_image_file_size
json.profile_image_updated_at        user.profile_image_updated_at

json.country do
  if user.country.present?
    json.id          user.country.id
    json.name        user.country.name
    json.iso_code    user.country.iso_code
    json.country_tld user.country.country_tld
    json.in_the_eu   user.country.in_the_eu
    json.continent   user.country.continent
  else
    json.nil!
  end
end

json.currency do
  if user.currency.present?
    json.id              user.currency.id
    json.name            user.currency.name
    json.iso_code        user.currency.iso_code
    json.leading_symbol  user.currency.leading_symbol
    json.trailing_symbol user.currency.trailing_symbol
  else
    json.nil!
  end
end

json.subscription_plan_category do
  if user.subscription_plan_category.present?
    json.id               user.subscription_plan_category.id
    json.name             user.subscription_plan_category.name
    json.guid             user.subscription_plan_category.guid
    json.available_from   user.subscription_plan_category.available_from
    json.available_from   user.subscription_plan_category.available_from
    json.sub_heading_text user.subscription_plan_category.sub_heading_text
  else
    json.nil!
  end
end

if @user_token.present?
  json.token @user_token
end

if @user_credentials.present?
  json.user_credentials @user_credentials
end
