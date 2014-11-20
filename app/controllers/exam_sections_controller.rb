class ExamSectionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @exam_sections = ExamSection.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @exam_section = ExamSection.new(sorting_order: 0, exam_level_id: params[:exam_level_id].to_i > 0 ? params[:exam_level_id].to_i : nil)
  end

  def edit
  end

  def create
    @exam_section = ExamSection.new(allowed_params)
    if @exam_section.save
      flash[:success] = I18n.t('controllers.exam_sections.create.flash.success')
      redirect_to exam_sections_url
    else
      render action: :new
    end
  end

  def update
    if @exam_section.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.exam_sections.update.flash.success')
      redirect_to exam_sections_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      ExamSection.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @exam_section.destroy
      flash[:success] = I18n.t('controllers.exam_sections.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.exam_sections.destroy.flash.error')
    end
    redirect_to exam_sections_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @exam_section = ExamSection.where(id: params[:id]).first
    end
    @exam_levels = ExamLevel.all_in_order
  end

  def allowed_params
    params.require(:exam_section).permit(:name, :name_url, :exam_level_id, :active, :sorting_order, :best_possible_first_attempt_score)
  end

end
