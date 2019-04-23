unless Rails.env.test?
    HomePage.create(name: 'Home', home: true, public_url: '/', seo_title: 'Learn Signal', seo_description: 'Learn Signal').tap do |home|
      home.save
      end
    HomePage.create(name: 'ACCA', public_url: '/acca', seo_title: 'Learn Signal', seo_description: 'Learn Signal').tap do |acca|
      acca.save
    end
    HomePage.create(name: 'CFA', public_url: '/cfa', seo_title: 'Learn Signal', seo_description: 'Learn Signal').tap do |cfa|
      cfa.save
    end
  end 