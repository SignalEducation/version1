# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'library/_register_upgrade_links' do

  describe 'visibility of Register Now link' do
    it 'shows the REGISTER NOW link' do
      assign(:group, build_stubbed(:group))
      assign(:course, build_stubbed(:course))

      render partial: 'library/register_upgrade_links', locals: { user: nil }

      expect(rendered).to match /Register Now/
    end
  end

  describe 'visibility of View Subscription Plans link' do
    before :each do
      def view.subscription_checkout_special_link(_id)
        'http://example.com'
      end
    end
    context 'for site_admins' do
      let(:user) { build_stubbed(:admin_user) }

      it 'does not show the UPGRADE NOW link' do
        assign(:group, build_stubbed(:group))
        assign(:course, build_stubbed(:course))

        render partial: 'library/register_upgrade_links', locals: { user: user }

        expect(rendered).not_to match /View Subscription Plans/
        expect(rendered).not_to match /Register Now/
      end
    end

    context 'for users with a subscription' do
      let(:user) { build_stubbed(:user) }

      before :each do
        allow(user).to receive(:valid_subscription_for_exam_body?).and_return true
      end

      it 'does not show the UPGRADE NOW link' do
        assign(:group, build_stubbed(:group))
        assign(:course, build_stubbed(:course))

        render partial: 'library/register_upgrade_links', locals: { user: user }

        expect(rendered).not_to match /View Subscription Plans/
        expect(rendered).not_to match /Register Now/
      end
    end

    context 'for users without a relevant subscription' do
      let(:user) { build_stubbed(:user) }

      before :each do
        allow(user).to receive(:valid_subscription_for_exam_body?).and_return false
      end

      it 'does not show the View Subscription Plans link' do
        assign(:group, build_stubbed(:group))
        assign(:course, build_stubbed(:course))

        render partial: 'library/register_upgrade_links', locals: { user: user }

        expect(rendered).to match /View Subscription Plans/
        expect(rendered).not_to match /Register Now/
      end
    end

    context 'for complimentary users' do
      let(:user) { build_stubbed(:comp_user) }

      it 'does not show the UPGRADE NOW link' do
        assign(:group, build_stubbed(:group))
        assign(:course, build_stubbed(:course))

        render partial: 'library/register_upgrade_links', locals: { user: user }

        expect(rendered).not_to match /View Subscription Plans/
        expect(rendered).not_to match /Register Now/
      end
    end
  end
end
