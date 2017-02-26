# == Schema Information
#
# Table name: course_module_jumbo_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_id                  :integer
#  name                              :string
#  minimum_question_count_per_quiz   :integer
#  maximum_question_count_per_quiz   :integer
#  total_number_of_questions         :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  name_url                          :string
#  best_possible_score_first_attempt :integer          default(0)
#  best_possible_score_retry         :integer          default(0)
#  destroyed_at                      :datetime
#  active                            :boolean          default(FALSE), not null
#

class CourseModuleJumboQuizzesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin content_manager))
  end
  before_action :get_variables

  def new
    @course_module_jumbo_quiz = CourseModuleJumboQuiz.new(course_module_id: params[:cm_id])
  end

  def edit
  end

  def create
    @course_module_jumbo_quiz = CourseModuleJumboQuiz.new(allowed_params)
    if @course_module_jumbo_quiz.save
      flash[:success] = I18n.t('controllers.course_module_jumbo_quizzes.create.flash.success')
      redirect_to subject_course_url(@course_module_jumbo_quiz.course_module.subject_course)
    else
      render action: :new
    end
  end

  def update
    if @course_module_jumbo_quiz.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_module_jumbo_quizzes.update.flash.success')
      redirect_to subject_course_url(@course_module_jumbo_quiz.parent.subject_course)
    else
      render action: :edit
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_module_jumbo_quiz = CourseModuleJumboQuiz.where(id: params[:id]).first
    end
    seo_title_maker(@course_module_jumbo_quiz.try(:name) || 'Jumbo Quizzes', '', true)
  end

  def allowed_params
    params.require(:course_module_jumbo_quiz).permit(:course_module_id, :name, :name_url, :minimum_question_count_per_quiz, :maximum_question_count_per_quiz, :total_number_of_questions, :active)
  end

end
