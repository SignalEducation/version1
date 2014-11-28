class CourseModuleElementsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor'])
  end
  before_action :get_variables

  def show
  end

  def new
    @course_module_element = CourseModuleElement.new(
        sorting_order: (CourseModuleElement.all.maximum(:sorting_order).to_i + 1),
        tutor_id: current_user.id,
        course_module_id: params[:cm_id].to_i)
    if params[:type] == 'video'
      @course_module_element.build_course_module_element_video
      @course_module_element.is_video = true
    elsif params[:type] == 'quiz'
      @course_module_element.is_quiz = true
      @course_module_element.build_course_module_element_quiz
      @course_module_element.course_module_element_quiz.add_an_empty_question
    end
    set_related_cmes
  end

  def edit
    if @course_module_element.is_quiz
      @course_module_element.course_module_element_quiz.add_an_empty_question
    end
    set_related_cmes
  end

  def create
    @course_module_element = CourseModuleElement.new(allowed_params)
    set_related_cmes
    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.create.flash.success')
      redirect_to course_module_special_link(@course_module_element.course_module)
    else
      render action: :new
    end
  end

  def update
    set_related_cmes
    if @course_module_element.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_module_elements.update.flash.success')
      redirect_to course_module_special_link(@course_module_element.course_module)
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseModuleElement.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @course_module_element.destroy
      flash[:success] = I18n.t('controllers.course_module_elements.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_module_elements.destroy.flash.error')
    end
    redirect_to course_module_elements_url
  end

  protected

  def create_new_question
    @course_module_element.course_module_element_quiz.quiz_questions.build
    @course_module_element.course_module_element_quiz.quiz_questions.last.quiz_contents.build(sorting_order: 1)
    4.times do |number|
      @course_module_element.course_module_element_quiz.quiz_questions.last.quiz_answers.build
      @course_module_element.course_module_element_quiz.quiz_questions.last.quiz_answers.last.quiz_contents.build(sorting_order: number + 1)
    end
  end

  def get_variables
    if params[:id].to_i > 0
      @course_module_element = CourseModuleElement.where(id: params[:id]).first
    end
    @tutors = User.all_tutors.all_in_order
    @raw_video_files = RawVideoFile.not_yet_assigned.all_in_order
    @letters = %w(A B C D)
  end

  def set_related_cmes
    if @course_module_element
      @related_cmes = @course_module_element.course_module.course_module_elements.all_videos
    end
  end

  def allowed_params
    params.require(:course_module_element).permit(
        :name,
        :name_url,
        :description,
        :estimated_time_in_seconds,
        :course_module_id,
        :course_module_element_video_id,
        :course_module_element_quiz_id,
        :sorting_order,
        :forum_topic_id,
        :tutor_id,
        :related_quiz_id,
        :related_video_id,
        :is_video,
        :is_quiz,
        course_module_element_video_attributes: [
            :course_module_element_id,
            :id,
            :raw_video_file_id,
            :tags,
            :difficulty_level,
            :estimated_study_time_seconds,
            :transcript],
        course_module_element_quiz_attributes: [
            :id,
            :course_module_element_id,
            :time_limit_seconds,
            :number_of_questions,
            :best_possible_score_retry,
            :course_module_jumbo_quiz_id,
            quiz_questions_attributes: [
                :id,
                :course_module_element_quiz_id,
                :difficulty_level,
                :solution_to_the_question,
                :hints,
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
                        :contains_mathjax,
                        :contains_image,
                        :sorting_order]
                ],
                quiz_contents_attributes: [
                    :id,
                    :quiz_question_id,
                    :quiz_answer_id,
                    :text_content,
                    :contains_mathjax,
                    :contains_image,
                    :sorting_order]
            ]
        ]
    )
  end

 end
