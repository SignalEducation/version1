# frozen_string_literal: true

class ExternalBannersController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[content_management_access marketing_resources_access])
  end
  before_action :management_layout, :get_variables
  before_action :set_external_banner, only: %i[show edit update destroy]

  def index
    @external_banners = ExternalBanner.all_without_parent.all_in_order
  end

  def show; end

  def new
    @external_banner = ExternalBanner.new(sorting_order: 1, active: true, background_colour: '#FFFFFF')
  end

  def edit; end

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
    render json: {}, status: :ok
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
    @exam_bodies = ExamBody.all_in_order
  end

  def set_external_banner
    @external_banner = ExternalBanner.where(id: params[:id]).first if params[:id].to_i > 0
  end

  def allowed_params
    params.require(:external_banner).permit(:name, :sorting_order, :active, :background_colour,
                                            :text_content, :exam_body_id, :basic_students, :paid_students)
  end
end
