class InstitutionsController < ApplicationController

  before_action :logged_in_required
  before_action except: [:index, :show] do
    ensure_user_is_of_type(['admin', 'content_manager'])
  end
  before_action only: [:index, :show] do
    ensure_user_is_of_type(['admin', 'tutor', 'content_manager'])
  end
  before_action :get_variables

  def index
    @subject_area = SubjectArea.where(name_url: params[:subject_area_url].to_s).first || SubjectArea.all_in_order.first
    @institutions = Institution.where(subject_area_id: @subject_area.id).paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @institution = Institution.new(sorting_order: 1,
                       subject_area_id: (params[:subject_area_id].to_i > 0 ?
                       params[:subject_area_id].to_i : nil) )
  end

  def edit
  end

  def create
    @institution = Institution.new(allowed_params)
    if @institution.save
      flash[:success] = I18n.t('controllers.institutions.create.flash.success')
      redirect_to filtered_institutions_url(@institution.subject_area.name_url)
    else
      render action: :new
    end
  end

  def update
    if @institution.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.institutions.update.flash.success')
      redirect_to filtered_institutions_url(@institution.subject_area.name_url)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Institution.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @institution.destroy
      flash[:success] = I18n.t('controllers.institutions.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.institutions.destroy.flash.error')
    end
    redirect_to institutions_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @institution = Institution.where(id: params[:id]).first
    end
    @subject_areas = SubjectArea.all_in_order
  end

  def allowed_params
    params.require(:institution).permit(:name, :short_name, :name_url, :description, :feedback_url, :help_desk_url, :subject_area_id, :sorting_order, :active, :background_colour_code, :seo_description, :seo_no_index)
  end

end
