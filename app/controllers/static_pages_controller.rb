class StaticPagesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'content_manager'])
  end
  before_action :get_variables

  def index
    @static_pages = StaticPage.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @static_page = StaticPage.new(language: 'en')
  end

  def edit
  end

  def create
    @static_page = StaticPage.new(allowed_params)
    @static_page.created_by = current_user.id
    if @static_page.save
      flash[:success] = I18n.t('controllers.static_pages.create.flash.success')
      redirect_to static_pages_url
    else
      render action: :new
    end
  end

  def update
    params[:static_page][:updated_by] = current_user.id
    if @static_page.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.static_pages.update.flash.success')
      redirect_to static_pages_url
    else
      render action: :edit
    end
  end

  def deliver_page
    if params[:first_element] == '404-page'
      render 'public/404.html', layout: nil
    else
      render 'static_pages/templates/stand_alone_page', layout: nil
    end
  end

  def destroy
    if @static_page.destroy
      flash[:success] = I18n.t('controllers.static_pages.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.static_pages.destroy.flash.error')
    end
    redirect_to static_pages_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @static_page = StaticPage.where(id: params[:id]).first
      binding.pry
      @static_page_uploads = StaticPageUpload.orphans_or_for_page(@static_page.id)
    else
      @static_page_uploads = StaticPageUpload.orphans.all_in_order
    end
  end

  def allowed_params
    params.require(:static_page).permit(:name, :publish_from, :publish_to, :allow_multiples, :public_url, :use_standard_page_template, :head_content, :body_content, :created_by, :updated_by, :add_to_navbar, :add_to_footer, :menu_label, :tooltip_text, :language, :mark_as_noindex, :mark_as_nofollow, :seo_title, :seo_description, :approved_country_ids, :default_page_for_this_url, :make_this_page_sticky, :logged_in_required)
  end

end
