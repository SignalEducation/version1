class CourseModuleElementsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor'])
  end
  before_action :get_variables

  def show
    @course_module_element = CourseModuleElement.find(params[:id])
    if @course_module_element.is_quiz
      @course_module_element_user_log = CourseModuleElementUserLog.new(
              course_module_id: @course_module_element.course_module_id,
              course_module_element_id: @course_module_element.id,
              user_id: current_user.try(:id)
              # session_guid: current_session_guid
              # -- not needed as this is not being persisted (yet!)
      )
      @course_module_element.course_module_element_quiz.number_of_questions.times do
        @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
      end
    end
    @demo_mode = true
  end

  def new
    @course_module_element = CourseModuleElement.new(
        sorting_order: (CourseModuleElement.all.maximum(:sorting_order).to_i + 1),
        course_module_id: params[:cm_id].to_i)
    @course_module_element.tutor_id = @course_module_element.course_module.tutor_id
    if params[:type] == 'video'
      @course_module_element.build_course_module_element_video
      @course_module_element.course_module_element_resources.build
      @course_module_element.is_video = true
    elsif params[:type] == 'quiz'
      spawn_quiz_children
    end
    set_related_cmes
  end

  def edit
    if @course_module_element.is_quiz
      @course_module_element.course_module_element_quiz.add_an_empty_question
    else
      @course_module_element.course_module_element_resources.build
    end
    set_related_cmes
  end

  def create
    if params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
      params[:course_module_element][:course_module_element_quiz_attributes].delete(:quiz_questions_attributes)
    end
    @course_module_element = CourseModuleElement.new(allowed_params)
    set_related_cmes
    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.create.flash.success')
      if params[:commit] == I18n.t('views.course_module_elements.form.save_and_add_another')
        redirect_to edit_course_module_element_url(@course_module_element.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
        redirect_to new_quiz_question_url(cme_quiz_id: @course_module_element.course_module_element_quiz.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.preview_button')
        redirect_to @course_module_element.course_module_element_quiz.quiz_questions.last
      else
        redirect_to course_module_special_link(@course_module_element.course_module)
      end
    else
      if params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
        spawn_quiz_children
      end
      if params[:commit] == t('views.general.save') && @course_module_element.is_video && @course_module_element.course_module_element_resources.empty?
        @course_module_element.course_module_element_resources.build
      end
      render action: :new
    end
  end

  def update
    set_related_cmes
    if @course_module_element.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.course_module_elements.update.flash.success')
      if params[:commit] == I18n.t('views.course_module_elements.form.save_and_add_another')
        redirect_to edit_course_module_element_url(@course_module_element.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.preview_button')
        redirect_to @course_module_element.course_module_element_quiz.quiz_questions.last
      else
        redirect_to course_module_special_link(@course_module_element.course_module)
      end
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
    redirect_to course_module_special_link(@course_module_element.course_module)
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_module_element = CourseModuleElement.where(id: params[:id]).first
    end
    @tutors = User.all_tutors.all_in_order
    @raw_video_files = RawVideoFile.not_yet_assigned.all_in_order
    @letters = ('A'..'Z').to_a
    seo_title_maker(@course_module_element.try(:name))
    @mathjax_required = true
  end

  def set_related_cmes
    if @course_module_element && @course_module_element.course_module
      @related_cmes = @course_module_element.course_module.course_module_elements.all_videos
    else
      @related_cmes = CourseModuleElement.none
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
        :active,
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
            :number_of_questions,
            :best_possible_score_retry,
            :course_module_jumbo_quiz_id,
            quiz_questions_attributes: [
                :id,
                :course_module_element_quiz_id,
                :difficulty_level,
                :hints,
                quiz_solutions_attributes: [
                    :id,
                    :quiz_question_id,
                    :quiz_answer_id,
                    :quiz_solution_id,
                    :text_content,
                    :contains_mathjax,
                    :contains_image,
                    :content_type,
                    :sorting_order
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
                        :contains_mathjax,
                        :contains_image,
                        :content_type,
                        :sorting_order]
                ],
                quiz_contents_attributes: [
                    :id,
                    :quiz_question_id,
                    :quiz_answer_id,
                    :text_content,
                    :contains_mathjax,
                    :contains_image,
                    :content_type,
                    :sorting_order]
            ]
        ],
        course_module_element_resources_attributes: [
                :id,
                :course_module_element_id,
                :name,
                :description,
                :web_url,
                :upload,
                :upload_file_name,
                :upload_content_type,
                :upload_file_size,
                :upload_updated_at
        ]
    )
  end

  def spawn_quiz_children
    @course_module_element.is_quiz = true
    @course_module_element.build_course_module_element_quiz
    @course_module_element.course_module_element_quiz.add_an_empty_question
    @course_module_element.course_module_element_quiz.quiz_questions.last.course_module_element_quiz_id = @course_module_element.course_module_element_quiz.id
  end

end
