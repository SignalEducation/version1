class SubjectAreasController < ApplicationController

  before_action :logged_in_required
  before_action except: [:index, :show] do
    ensure_user_is_of_type(['admin'])
  end
  before_action only: [:index, :show] do
    ensure_user_is_of_type(['admin', 'tutor'])
  end
  before_action :get_variables

  def index
    @subject_areas = SubjectArea.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @subject_area = SubjectArea.new(sorting_order: 1)
  end

  def edit
  end

  def create
    @subject_area = SubjectArea.new(allowed_params)
    if @subject_area.save
      flash[:success] = I18n.t('controllers.subject_areas.create.flash.success')
      redirect_to subject_areas_url
    else
      render action: :new
    end
  end

  def update
    if @subject_area.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.subject_areas.update.flash.success')
      redirect_to subject_areas_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      SubjectArea.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @subject_area.destroy
      flash[:success] = I18n.t('controllers.subject_areas.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.subject_areas.destroy.flash.error')
    end
    redirect_to subject_areas_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @subject_area = SubjectArea.where(id: params[:id]).first
    end
    seo_title_maker(@subject_area.try(:name))
  end

  def allowed_params
    params.require(:subject_area).permit(:name, :name_url, :sorting_order, :active)
  end

end
