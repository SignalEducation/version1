class QualificationsController < ApplicationController

  before_action :logged_in_required
  before_action except: [:index, :show] do
    ensure_user_is_of_type(['admin'])
  end
  before_action only: [:index, :show] do
    ensure_user_is_of_type(['tutor'])
  end
  before_action :get_variables

  def index
    @institution = Institution.where(name_url: params[:institution_url].to_s).first || Institution.all_in_order.first
    @qualifications = @institution ?
           Qualification.where(institution_id: @institution.try(:id)).paginate(per_page: 50, page: params[:page]).all_in_order :
           Qualification.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @qualification = Qualification.new(sorting_order: 1,
                              institution_id: (params[:institution_id].to_i > 0 ?
                              params[:institution_id].to_i : nil))
  end

  def edit
  end

  def create
    @qualification = Qualification.new(allowed_params)
    if @qualification.save
      flash[:success] = I18n.t('controllers.qualifications.create.flash.success')
      redirect_to qualifications_filtered_path(@qualification.institution.name_url)
    else
      render action: :new
    end
  end

  def update
    if @qualification.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.qualifications.update.flash.success')
      redirect_to qualifications_filtered_path(@qualification.institution.name_url)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Qualification.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
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
    seo_title_maker(@qualification.try(:name))
  end

  def allowed_params
    params.require(:qualification).permit(:institution_id, :name, :name_url, :sorting_order, :active, :cpd_hours_required_per_year)
  end

end
