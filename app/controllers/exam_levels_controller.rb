class ExamLevelsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @exam_levels = ExamLevel.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @exam_level = ExamLevel.new
  end

  def edit
  end

  def create
    @exam_level = ExamLevel.new(allowed_params)
    if @exam_level.save
      flash[:success] = I18n.t('controllers.exam_levels.create.flash.success')
      redirect_to exam_levels_url
    else
      render action: :new
    end
  end

  def update
    if @exam_level.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.exam_levels.update.flash.success')
      redirect_to exam_levels_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      ExamLevel.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @exam_level.destroy
      flash[:success] = I18n.t('controllers.exam_levels.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.exam_levels.destroy.flash.error')
    end
    redirect_to exam_levels_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @exam_level = ExamLevel.where(id: params[:id]).first
    end
    @qualifications = Qualification.all_in_order
  end

  def allowed_params
    params.require(:exam_level).permit(:qualification_id, :name, :name_url, :is_cpd, :sorting_order, :active)
  end

end
