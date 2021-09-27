require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#tick_or_cross' do
    it 'return a tick span' do
      expect(tick_or_cross(true)).to include('#21CE99')
      expect(tick_or_cross(true)).to include('glyphicon-ok')
    end

    it 'return a cross span' do
      expect(tick_or_cross(false)).to include('#eb4242')
      expect(tick_or_cross(false)).to include('glyphicon-remove')
    end
  end

  describe '#red_or_green_arrow' do
    it 'return a green arrow' do
      expect(red_or_green_arrow(true, 'arrow_forward')).to include('#21CE99')
    end

    it 'return a red arrow' do
      expect(red_or_green_arrow(false, 'arrow_forward')).to include('#eb4242')
    end
  end

  describe '#red_or_green_text' do
    it 'return a green text' do
      expect(red_or_green_text(true, 'A')).to include('#21CE99')
    end

    it 'return a red text' do
      expect(red_or_green_text(false, 'B')).to include('#eb4242')
    end
  end

  describe '#red_or_green_tick' do
    it 'return a green check mark' do
      expect(red_or_green_tick(true)).to include('check')
    end

    it 'return a red check mark' do
      expect(red_or_green_tick(false)).to include('close')
    end
  end

  describe '#sidepanel_border_radius' do
    it 'contains active step class' do
      expect(sidepanel_border_radius(4, 3, 12)).to include('active-step')
    end

    it 'contains first step class' do
      expect(sidepanel_border_radius(4, 0, 12)).to include('step-first-step')
    end

    it 'contains last step class' do
      expect(sidepanel_border_radius(4, 11, 12)).to include('step-last-step')
    end
  end

  describe '#flagged_for_review' do
    it 'return a flagged span' do
      expect(flagged_for_review(true)).to include('#eb4242')
    end

    it 'return a unflagged span' do
      expect(flagged_for_review(false)).to include('#333e4c')
    end
  end

  describe '#number_in_local_currency' do
    let(:currency) { build_stubbed(:currency) }

    it 'return a flagged span' do
      amount = rand(01..99)
      expect(number_in_local_currency(amount, currency)).to eq("#{currency.leading_symbol}#{amount}.00")
    end
  end

  describe '#number_in_local_currency_no_precision' do
    let(:currency) { build_stubbed(:currency) }

    it 'return a flagged span' do
      amount = rand(01..99)
      expect(number_in_local_currency_no_precision(amount, currency)).to eq("#{currency.leading_symbol}#{amount}")
    end
  end

  describe '#sanitizer' do
    it 'return a sanitized text' do
      html = '<h2 title="I\'m a header">The title Attribute</h2>'
      expect(sanitizer(html)).to eq('The title Attribute')
    end
  end

  describe '#head_sanitizer' do
    it 'return a sanitized text' do
      html = '<title>Page Title</title>'
      expect(head_sanitizer(html)).to eq('<title>Page Title</title>')
    end
  end

  describe '#body_sanitizer' do
    it 'return a sanitized text' do
      html = '<p>Note that the form itself is not visible.</p>'
      expect(body_sanitizer(html)).to eq('<p>Note that the form itself is not visible.</p>')
    end
  end

  describe '#image_optimizer' do
    context 'when on a desktop' do
      it 'passes the original large resolution image' do
        allow_any_instance_of(ApplicationHelper).to receive(:verify_user_device).and_return('desktop')
        expect(image_optimizer('/images/red-background.png')).to eq('/images/red-background.png')
      end
    end

    context 'when on a mobile and mobile image exists' do
      it 'passes the optimized version of image' do
        allow_any_instance_of(ApplicationHelper).to receive(:verify_user_device).and_return('mobile')
        allow_any_instance_of(ApplicationHelper).to receive(:asset_exists?).and_return(true)
        expect(image_optimizer('/images/red-background.png')).to eq('/images/red-background-mob.png')
      end
    end

    context 'when on a mobile and mobile image does not exist' do
      it 'passes the original large resolution image' do
        allow_any_instance_of(ApplicationHelper).to receive(:verify_user_device).and_return('mobile')
        allow_any_instance_of(ApplicationHelper).to receive(:asset_exists?).and_return(false)
        expect(image_optimizer('/images/red-background.png')).to eq('/images/red-background.png')
      end
    end
  end

  describe '#verify_user_device' do
    it 'returns Desktop' do
      allow(request).to receive(:user_agent).and_return('desktop')
      expect(verify_user_device).to eq('desktop')
    end

    it 'returns Tablet' do
      allow(request).to receive(:user_agent).and_return('tablet')
      expect(verify_user_device).to eq('tablet')
    end

    it 'returns Mobile' do
      allow(request).to receive(:user_agent).and_return('mobile')
      expect(verify_user_device).to eq('mobile')
    end
  end

  describe '#asset_exists?' do
    xit 'returns true for existing precompiled asset' do
      Rails.configuration.assets.compile = true
      expect(asset_exists?('red-background-mob.png')).to eq(true)
    end

    it 'returns true if asset exists but has not been precompiled' do
      Rails.configuration.assets.compile = nil
      expect(asset_exists?('red-background-mob.png')).to eq(true)
    end

    it 'returns false for non existing asset' do
      expect(asset_exists?('fake-image-not-real-00000-mob.png')).to eq(false)
    end
  end

  describe '#seconds_to_time' do
    context 'less then 3600 seconds' do
      it 'return seconds formated to minutes:seconds' do
        expect(seconds_to_time(300)).to eq('05:00')
      end
    end

    context 'more then 3600 seconds' do
      it 'return seconds formated to hours:minutes:seconds' do
        expect(seconds_to_time(5000)).to eq('01:23:20')
      end
    end
  end

  describe '#humanize_time' do
    context 'less then 3600 seconds' do
      it 'return seconds formated to minutes:seconds' do
        expect(humanize_time(300)).to eq('05m 00s')
      end
    end

    context 'more then 3600 seconds' do
      it 'return seconds formated to hours:minutes:seconds' do
        expect(humanize_time(5000)).to eq('01h 23m')
      end
    end
  end

  describe '#simple_hour_time' do
    context 'less then 3600 seconds' do
      it 'return minutes' do
        expect(simple_hour_time(300)).to eq('5m')
      end
    end

    context 'more then 3600 seconds' do
      it 'return hours' do
        expect(simple_hour_time(5000)).to eq('1h')
      end
    end
  end

  describe '#simple_time' do
    context 'less then 3600 seconds' do
      it 'return minutes' do
        expect(simple_time(300)).to eq('05m')
      end
    end

    context 'more then 3600 seconds' do
      it 'return hours' do
        expect(simple_time(5000)).to eq('01h')
      end
    end
  end

  describe '#humanize_datetime' do
    it 'humanize date' do
      date = DateTime.new
      expect(humanize_datetime(date)).to eq(date.utc.strftime('%d %b %y'))
    end
  end

  describe '#humanize_datetime_full' do
    it 'humanize date' do
      date = DateTime.new
      expect(humanize_datetime_full(date)).to eq(date.utc.strftime('%d %B %Y'))
    end
  end

  describe '#timer_datetime' do
    it 'humanize date' do
      date = DateTime.new
      expect(timer_datetime(date)).to eq(date.utc.strftime('%Y/%m/%d %H:%M:%S'))
    end
  end

  describe '#humanize_date_and_month' do
    context 'nil date' do
      it 'return -' do
        expect(humanize_date_and_month(nil)).to eq('-')
      end
    end

    context 'more then 3600 seconds' do
      it 'return formated date' do
        date = DateTime.new
        expect(humanize_date_and_month(date)).to eq(date.utc.strftime('%d %b'))
      end
    end
  end

  describe '#exam_sitting_date' do
    it 'humanize date' do
      date = DateTime.new
      expect(exam_sitting_date(date)).to eq(date.utc.strftime('%B %Y'))
    end
  end

  describe '#referral_code_sharing_url' do
    let(:referral) { build(:referral_code) }

    it 'return refer a friend link' do
      expect(referral_code_sharing_url(referral)).to eq("#{refer_a_friend_url}/?ref_code=#{referral.code}")
    end
  end

  describe '#plan_interval' do
    context '1 as interval' do
      it 'return paym' do
        expect(plan_interval(1)).to eq('paym')
      end
    end

    context '3 as interval' do
      it 'return payq' do
        expect(plan_interval(3)).to eq('payq')
      end
    end

    context 'any other interval' do
      it 'return paya' do
        expect(plan_interval(rand(4..99))).to eq('paya')
      end
    end
  end

  describe '#plan_interval_alt' do
    context '1 as interval' do
      it 'monthly' do
        expect(plan_interval_alt(1)).to include('plan-monthly')
      end
    end

    context '3 as interval' do
      it 'quarterly' do
        expect(plan_interval_alt(3)).to include('plan-quarterly')
      end
    end

    context 'any other interval' do
      it 'yearly' do
        expect(plan_interval_alt(12)).to include('plan-yearly')
      end
    end
  end

  describe '#sub_interval_alt' do
    context '1 as interval' do
      it 'monthly' do
        expect(sub_interval_alt(1)).to include('sub-monthly')
      end
    end

    context '3 as interval' do
      it 'quarterly' do
        expect(sub_interval_alt(3)).to include('sub-quarterly')
      end
    end

    context 'any other interval' do
      it 'yearly' do
        expect(sub_interval_alt(12)).to include('sub-yearly')
      end
    end
  end

  describe '#sub_interval_color' do
    context '1 as interval' do
      it 'monthly' do
        expect(sub_interval_color(1)).to include('monthly-color')
      end
    end

    context '3 as interval' do
      it 'quarterly' do
        expect(sub_interval_color(3)).to include('quarterly-color')
      end
    end

    context 'any other interval' do
      it 'yearly' do
        expect(sub_interval_color(12)).to include('yearly-color')
      end
    end
  end

   describe '#sub_interval_btn_color' do
    context '1 as interval' do
      it 'cyan' do
        expect(sub_interval_btn_color(1)).to include('cyan')
      end
    end

    context '3 as interval' do
      it 'red' do
        expect(sub_interval_btn_color(3)).to include('red')
      end
    end

    context 'any other interval' do
      it 'purple' do
        expect(sub_interval_btn_color(12)).to include('purple')
      end
    end
  end

  describe '#humanize_stripe_date_full' do
    context 'with a date passed in' do
      it 'returns the correctly formatted date' do
        expect(humanize_stripe_date_full(Date.new(2018,11,16))).to eq '16 November 2018'
      end
    end

    context 'without a date' do
      it 'returns the correctly formatted date' do
        Timecop.freeze(2018, 11, 16) do
          expect(humanize_stripe_date_full).to eq '16 December 2018'
        end
      end
    end
  end

  describe '#humanize_stripe_date' do
    context 'with a date passed in' do
      it 'returns the correctly formatted date' do
        expect(humanize_stripe_date(Date.new(2018,11,16))).to eq '16 Nov 18'
      end
    end

    context 'without a date' do
      it 'returns the correctly formatted date' do
        Timecop.freeze(2018, 11, 16) do
          expect(humanize_stripe_date).to eq '16 Dec 18'
        end
      end
    end
  end

  describe '#navbar_landing_page_menu' do
    context 'about_us link' do
      let(:page) { build(:home_page, :about_us) }

      it 'returns the correctly formatted date' do
        expect(navbar_landing_page_menu(page)).to include('onclick')
        expect(navbar_landing_page_menu(page)).to include('clicks_header_about_us')
      end
    end

    context 'any other link' do
      let(:page) { build(:home_page) }

      it 'returns the correctly formatted date' do
        expect(navbar_landing_page_menu(page)).to include('onclick=""')
      end
    end
  end

  describe '#verify_email_message' do
    context 'remain days to verify' do
      let(:days) { rand(1..7) }

      it 'returns a message with the remain days' do
        expect(verify_email_message(days)).to eq("Please verify your email address within <span>#{days}</span> days to continue using your free subscription.")
      end
    end

    context 'no more days remains to verufy' do
      it 'returns a message asking to user verify the email' do
        expect(verify_email_message(0)).to eq('Please <span>verify</span> your email to continue free tier subscription.')
      end
    end
  end
end
