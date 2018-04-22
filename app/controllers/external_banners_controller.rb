# == Schema Information
#
# Table name: external_banners
#
#  id                 :integer          not null, primary key
#  name               :string
#  sorting_order      :integer
#  active             :boolean          default(FALSE)
#  background_colour  :string
#  text_content       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_sessions      :boolean          default(FALSE)
#  library            :boolean          default(FALSE)
#  subscription_plans :boolean          default(FALSE)
#  footer_pages       :boolean          default(FALSE)
#  student_sign_ups   :boolean          default(FALSE)
#

class ExternalBannersController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(content_management_access marketing_resources_access))
  end
  before_action :get_variables

  def index
    @external_banners = ExternalBanner.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
    #Preview for managers
    @banner = @external_banner
  end

  def new
    @external_banner = ExternalBanner.new(sorting_order: 1, active: true, background_colour: '#FFFFFF')
  end

  def edit
  end

  def create
    @external_banner = ExternalBanner.new(allowed_params)
    if @external_banner.save
      flash[:success] = I18n.t('controllers.external_banners.create.flash.success')
      redirect_to external_banners_url
    else
      render action: :new
    end
  end

  def update
    if @external_banner.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.external_banners.update.flash.success')
      redirect_to external_banners_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      ExternalBanner.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @external_banner.destroy
      flash[:success] = I18n.t('controllers.external_banners.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.external_banners.destroy.flash.error')
    end
    redirect_to external_banners_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @external_banner = ExternalBanner.where(id: params[:id]).first
    end
    @layout = 'management'
  end

  def allowed_params
    params.require(:external_banner).permit(:name, :sorting_order, :active, :background_colour, :text_content,
                                            :user_sessions, :library, :subscription_plans, :footer_pages, :student_sign_ups)
  end

end
