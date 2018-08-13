# == Schema Information
#
# Table name: content_pages
#
#  id              :integer          not null, primary key
#  name            :string
#  public_url      :string
#  seo_title       :string
#  seo_description :text
#  text_content    :text
#  h1_text         :string
#  h1_subtext      :string
#  nav_type        :string
#  footer_link     :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  active          :boolean          default(FALSE)
#

class ContentPagesController < ApplicationController

  before_action :logged_in_required, except: [:show]
  before_action except: [:show] do
    ensure_user_has_access_rights(%w(system_requirements_access marketing_resources_access))
  end
  before_action :get_variables, except: [:show]

  def index
    @content_pages = ContentPage.all_in_order
  end

  def show
    @content_page = ContentPage.where(public_url: params[:content_public_url]).first
    if @content_page && @content_page.active
      @banner = @content_page.external_banners.first if @content_page.external_banners.any?
      seo_title_maker(@content_page.seo_title, @content_page.seo_description, nil)
      if @content_page.standard_nav?
        @navbar = true
        @top_margin = true
      else
        @navbar = false
        @top_margin = false
      end
      @footer = true
    else
      redirect_to root_url
    end
  end

  def new
    @content_page = ContentPage.new
    @content_page.external_banners.build(sorting_order: 1, active: true, background_colour: '#FFFFFF')
  end

  def edit
    @content_page.external_banners.build(sorting_order: 1, active: true, background_colour: '#FFFFFF') unless @content_page.external_banners.any?
  end

  def create
    @content_page = ContentPage.new(allowed_params)
    if @content_page.save
      flash[:success] = I18n.t('controllers.content_pages.create.flash.success')
      redirect_to content_pages_url
    else
      render action: :new
    end
  end

  def update
    if @content_page.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.content_pages.update.flash.success')
      redirect_to content_pages_url
    else
      render action: :edit
    end
  end


  def destroy
    if @content_page.destroy
      flash[:success] = I18n.t('controllers.content_pages.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.content_pages.destroy.flash.error')
    end
    redirect_to content_pages_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @content_page = ContentPage.where(id: params[:id]).first
    end
    @layout = 'management'
  end

  def allowed_params
    params.require(:content_page).permit(:name, :public_url, :seo_title, :seo_description, :text_content,
                                         :h1_text, :h1_subtext, :nav_type, :footer_link, :active,
                                         external_banners_attributes: [:id, :name, :background_colour,
                                                                       :text_content, :sorting_order,
                                                                       :_destroy])
  end

end
