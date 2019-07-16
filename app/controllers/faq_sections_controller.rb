# frozen_string_literal: true

class FaqSectionsController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[content_management_access marketing_resources_access])
  end
  before_action :get_variables

  def index
    @faq_sections = FaqSection.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def new
    @faq_section = FaqSection.new(sorting_order: 1)
  end

  def edit; end

  def create
    @faq_section = FaqSection.new(allowed_params)

    if @faq_section.save
      flash[:success] = I18n.t('controllers.faq_sections.create.flash.success')
      redirect_to public_resources_url
    else
      render action: :new
    end
  end

  def update
    if @faq_section.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.faq_sections.update.flash.success')
      redirect_to public_resources_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      FaqSection.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end

    render json: {}, status: :ok
  end

  def destroy
    if @faq_section.destroy
      flash[:success] = I18n.t('controllers.faq_sections.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.faq_sections.destroy.flash.error')
    end

    redirect_to public_resources_url
  end

  protected

  def get_variables
    @faq_section = FaqSection.where(id: params[:id]).first if params[:id].to_i > 0
    @layout = 'management'
  end

  def allowed_params
    params.require(:faq_section).permit(:name, :name_url, :description, :active, :sorting_order)
  end
end
