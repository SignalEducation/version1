require 'rails_helper'
require 'mandrill_client'

describe MandrillClient do
  let(:user) { build(:user) }

  describe 'template methods' do
    before do
      @client = MandrillClient.new(user)

      allow_any_instance_of(MandrillClient).to receive(:send_template) do |template, msg|
        [template, msg]
      end
    end

    it 'send_verification_email' do
      response = @client.send_verification_email('verification_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('email-verification-190429')
    end

    it 'admin_invite' do
      response = @client.admin_invite('verification_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('admin-invite-190605')
    end

    it 'csv_webinar_invite' do
      response = @client.csv_webinar_invite('verification_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('webinar_invite_170824')
    end

    it 'password_reset_email' do
      response = @client.password_reset_email('password_reset_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('password-reset-190605')
    end

    it 'send_set_password_email' do
      response = @client.send_set_password_email('set_password_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('set-password-09-01-18')
    end

    it 'send_card_payment_failed_email' do
      response = @client.send_card_payment_failed_email('account_settings_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('card-payment-failed-190605')
    end

    it 'send_account_suspended_email' do
      response = @client.send_account_suspended_email

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('account-suspended-190605')
    end

    it 'send_successful_payment_email' do
      response = @client.send_successful_payment_email('account_url', 'invoice_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('payment-invoice-new-branding-190605')
    end

    it 'send_referral_discount_email' do
      response = @client.send_referral_discount_email('amount')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('referral-discount-20-02-17')
    end

    it 'send_mock_exam_email' do
      response = @client.send_mock_exam_email('account_url', 'product_name', 'guid')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('mock-exam-confirmation-190510')
    end

    it 'send_correction_returned_email' do
      response = @client.send_correction_returned_email('account_url', 'product_name')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('corrections-returned-190510')
    end

    it 'send_supscription_notification_email' do
      response = @client.send_supscription_notification_email

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('subscription-due-201908')
    end

    it 'send_onboarding_complete_email' do
      response = @client.send_onboarding_complete_email('subscription_url', 'course', 'unsubscribe_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('onboarding-complete-140720')
    end

    it 'send_onboarding_expired_email' do
      response = @client.send_onboarding_expired_email('subscription_url', 'course', 'unsubscribe_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('onboarding-expired-140720')
    end

    it 'send_onboarding_content_email' do
      response = @client.send_onboarding_content_email('1', 'subject_line', 'course', 'next_step', 'content_url', 'unsubscribe_url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('onboarding-day-1-140720')
    end

    it 'send_survey_email' do
      response = @client.send_survey_email('url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('course-completion-survey-190605')
    end

    it 'send_sca_confirmation_email' do
      response = @client.send_sca_confirmation_email('url')

      expect(response.first).to be_kind_of(MandrillClient)
      expect(response.last).to eq('invoice-actionable-2019-08-13')
    end
  end

  describe 'private methods' do
    before do
      stub_request(:post, 'https://mandrillapp.com/api/1.0/messages/send-template.json').
        with(body: '{"template_name":"template_slug","template_content":null,"message":{"msg":"msg"},"async":false,"ip_pool":null,"send_at":null,"key":"uKK_pGl-9PK54IhUzx5Ajg"}',
             headers: { 'Accept' => '*/*', 'Content-Type' => 'application/json', 'Host' => 'mandrillapp.com:443', 'User-Agent' => 'excon/0.71.0' }).
        to_return { |request| { body: request.body } }
    end

    it '.send_template' do
      client = MandrillClient.new(user)
      response = client.send(:send_template, 'template_slug', msg: 'msg')

      expect(response['message']['msg']).to eq('msg')
      expect(response['template_name']).to eq('template_slug')
    end
  end
end
