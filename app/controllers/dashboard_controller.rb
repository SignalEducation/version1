class DashboardController < ApplicationController

  before_action :logged_in_required

  def index
    seo_title_maker('personalised to you')
  end

end
