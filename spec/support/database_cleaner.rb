RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction

    if (MarketingCategory.where(name: "SEO and Direct").count == 0)
      @marketing_category = FactoryGirl.create(:marketing_category, name: "SEO and Direct")
      FactoryGirl.create(:marketing_token, code: 'seo', marketing_category_id: @marketing_category.id)
      FactoryGirl.create(:marketing_token, code: 'direct', marketing_category_id: @marketing_category.id)
    end
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
    FactoryGirl.reload
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
