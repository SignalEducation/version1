unless Rails.env.test?
    HomePage.create(name: 'Home', home: true, public_url: '/',
                    seo_title: 'LearnSignal',
                    seo_description: 'LearnSignal').tap do |home|
      home.save
      end
    HomePage.create(name: 'ACCA Basic Registration', public_url: '/acca_basic',
                    group_id: 1,
                    footer_link: true,
                    registration_form: true,
                    login_form: true,
                    seo_title: 'ACCA Basic - Learn Signal',
                    seo_description: 'ACCA Basic - Learn Signal').tap do |acca1|
      acca1.save
    end
    HomePage.create(name: 'ACCA Subscription', public_url: '/acca_subscription',
                    group_id: 1,
                    footer_link: true,
                    registration_form: true,
                    login_form: true,
                    pricing_section: true,
                    preferred_payment_frequency: 12,
                    seo_title: 'ACCA Sub - Learn Signal',
                    seo_description: 'ACCA Sub - Learn Signal').tap do |acca2|
      acca2.save
    end
  end