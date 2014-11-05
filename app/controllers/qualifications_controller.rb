class QualificationsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @qualifications = Qualification.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @qualification = Qualification.new
  end

  def edit
  end

  def create
    @qualification = Qualification.new(allowed_params)
    if @qualification.save
      flash[:success] = I18n.t('controllers.qualifications.create.flash.success')
      redirect_to qualifications_url
    else
      render action: :new
    end
  end

  def update
    if @qualification.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.qualifications.update.flash.success')
      redirect_to qualifications_url
    else
      render action: :edit
    end
  end

  def destroy
    if @qualification.destroy
      flash[:success] = I18n.t('controllers.qualifications.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.qualifications.destroy.flash.error')
    end
    redirect_to qualifications_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @qualification = Qualification.where(id: params[:id]).first
    end
    @institutions = Institution.all_in_order
  end

  def allowed_params
    params.require(:qualification).permit(:institution_id, :name, :name_url, :sorting_order, :active, :cpd_hours_required_per_year)
  end

end
