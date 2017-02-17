# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string
#  hints                         :text
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#  sorting_order                 :integer
#

class QuizQuestionsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor', 'content_manager'])
  end
  before_action :get_variables, except: :reorder

  def show

  end

  def new
    @quiz_question.quiz_contents.build
    @quiz_question.quiz_solutions.build
    @quiz_question.course_module_element_quiz.course_module_element.course_module.subject_course.default_number_of_possible_exam_answers.times do
      @quiz_question.quiz_answers.build
      @quiz_question.quiz_answers.last.quiz_contents.build
    end
  end

  def edit
  end

  def create
    if @quiz_question.save
      flash[:success] = I18n.t('controllers.quiz_questions.create.flash.success')
      redirect_to edit_course_module_element_url(@quiz_question.course_module_element_id)
    else
      render action: :new
    end
  end

  def update
    if @quiz_question.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.quiz_questions.update.flash.success')
      redirect_to edit_course_module_element_url(@quiz_question.course_module_element_id)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      QuizQuestion.find(the_id.to_i).update_attributes!(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @quiz_question.destroy
      flash[:success] = I18n.t('controllers.quiz_questions.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.quiz_questions.destroy.flash.error')
    end
    redirect_to edit_course_module_element_url(@quiz_question.course_module_element_id)
  end

  protected

  def get_variables
    @mathjax_required = true
    if params[:id].to_i > 0
      @quiz_question = QuizQuestion.find(params[:id])
    elsif params[:cme_quiz_id].to_i > 0
      @quiz_question = QuizQuestion.new(course_module_element_quiz_id: params[:cme_quiz_id])
    else
      @quiz_question = QuizQuestion.new(allowed_params)
    end
    @quiz_questions = QuizQuestion.all_in_order
    if @quiz_question.id.nil?
      @cme_videos = CourseModuleElement.all_videos.all_in_order
    else
      @cme_videos = CourseModuleElement.where(course_module_id: @quiz_question.course_module_element_quiz.course_module_element.course_module_id).all_videos.all_in_order
    end
    seo_title_maker("Quiz Questions #{@quiz_question.try(:id)}", '', true)
  end

  def allowed_params
    params.require(:quiz_question).permit(
        :course_module_element_quiz_id,
        :difficulty_level,
        :sorting_order,
        :hints,
        quiz_solutions_attributes: [
            :id,
            :quiz_question_id,
            :quiz_answer_id,
            :quiz_solution_id,
            :text_content,
            :content_type,
            :sorting_order,
            :_destroy,
            :image
        ],
        quiz_answers_attributes: [
            :id,
            :quiz_question_id,
            :correct,
            :degree_of_wrongness,
            :wrong_answer_explanation_text,
            :wrong_answer_video_id,
            quiz_contents_attributes: [
                :id,
                :quiz_question_id,
                :quiz_answer_id,
                :text_content,
                :sorting_order,
                :_destroy,
                :content_type,
                :image
            ]
        ],
        quiz_contents_attributes: [
            :id,
            :quiz_question_id,
            :quiz_answer_id,
            :text_content,
            :sorting_order,
            :_destroy,
            :content_type,
            :image
        ]
    )
  end

end
