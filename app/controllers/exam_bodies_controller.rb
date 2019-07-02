# frozen_string_literal: true

class ExamBodiesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access])
  end
  before_action :get_variables

  def index
    @exam_bodies = ExamBody.all_in_order
  end

  def show; end

  def new
    @exam_body = ExamBody.new
  end

  def edit; end

  def create
    @exam_body = ExamBody.new(allowed_params)

    if @exam_body.save
      flash[:success] = I18n.t('controllers.exam_bodies.create.flash.success')
      redirect_to exam_bodies_url
    else
      render action: :new
    end
  end

  def update
    if @exam_body.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.exam_bodies.update.flash.success')
      redirect_to exam_bodies_url
    else
      render action: :edit
    end
  end

  def destroy
    if @exam_body.destroy
      flash[:success] = I18n.t('controllers.exam_bodies.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.exam_bodies.destroy.flash.error')
    end

    redirect_to exam_bodies_url
  end

  protected

  def get_variables
    @exam_body = ExamBody.where(id: params[:id]).first if params[:id].to_i > 0
    @layout = 'management'
  end

  def allowed_params
    params.require(:exam_body).permit(:name, :url, :active, :has_sittings,
                                      :preferred_payment_frequency,
                                      :subscription_page_subheading_text,
                                      :constructed_response_intro_heading,
                                      :constructed_response_intro_text,
                                      :logo_image, :registration_form_heading,
                                      :login_form_heading)
  end
end
