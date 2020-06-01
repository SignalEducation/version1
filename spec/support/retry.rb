# frozen_string_literal: true

RSpec.configure do |config|
  # run retry only on features
  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end

  config.retry_callback = proc do |ex|
    Capybara.reset! if ex.metadata[:js]
  end
end
