class CoursesController < ApplicationController

  def show
    @mathjax_required = true
    @course_module = CourseModule.where(name_url: params[:course_module_name_url]).first
    @course_module_element = CourseModuleElement.where(name_url: params[:course_module_element_name_url]).first
    @course_module_jumbo_quiz = @course_module.course_module_jumbo_quiz if @course_module.course_module_jumbo_quiz.try(:name_url) == params[:course_module_element_name_url]
    @course_module_element ||= @course_module.course_module_elements.all_in_order.first unless @course_module_jumbo_quiz

    if @course_module_element.nil? && @course_module.nil?
      # The URL is out of date or wrong.
      @exam_section = params[:exam_section_name_url] == 'all' ?
            nil :
            ExamSection.where(name_url: params[:exam_section_name_url]).first
      @exam_level = ExamLevel.where(name_url: params[:exam_level_name_url]).first
      @qualification = Qualification.where(name_url: params[:qualification_name_url]).first
      @institution = Institution.where(name_url: params[:institution_name_url]).first
      @subject_area = SubjectArea.where(name_url: params[:subject_area_name_url]).first
      flash[:warning] = t('controllers.courses.show.warning')
      Rails.logger.warn "WARN: CoursesController#show failed to find content. Params: #{request.filtered_parameters}."
      redirect_to library_special_link(@exam_section || @exam_level || @qualification || @institution || @subject_area || nil)
    else
      # The URL worked out Okay
      if @course_module_element.try(:is_quiz)
        set_up_quiz
      elsif @course_module_jumbo_quiz
        set_up_jumbo_quiz
      elsif @course_module_element.try(:is_video)
        create_a_cme_user_log
      end
    end
  end

  def create # course_module_element_user_log and children
    @mathjax_required = true
    @course_module_element_user_log = CourseModuleElementUserLog.new(allowed_params)
    @course_module_element_user_log.session_guid = current_session_guid
    @course_module_element_user_log.element_completed = true
    @course_module_element_user_log.time_taken_in_seconds += Time.now.to_i
    unless @course_module_element_user_log.save
      Rails.logger.error "ERROR: CoursesController#create: Failed to save. CME-UserLog.inspect #{@course_module_element_user_log.errors.inspect}."
      flash[:error] = I18n.t('controllers.courses.create.flash.error')
    end
    if params[:demo_mode] == 'yes'
      redirect_to course_module_element_path(@course_module_element_user_log.course_module_element)
    else
      @course_module_element = @course_module_element_user_log.course_module_element
      @course_module = @course_module_element_user_log.course_module
      @results = true
      render :show
    end
  end

  private

  def allowed_params
    params.require(:course_module_element_user_log).permit(
            :course_module_id,
            :course_module_element_id,
            :course_module_jumbo_quiz_id,
            :user_id,
            #:session_guid,
            #:element_completed,
            :time_taken_in_seconds,
            #:quiz_score_actual,
            #:quiz_score_potential,
            #:is_video,
            #:is_quiz,
            #:is_jumbo_quiz,
            #:latest_attempt,
            :corporate_customer_id,
            quiz_attempts_attributes: [
                    :id,
                    :user_id,
                    :quiz_question_id,
                    :quiz_answer_id
            ]
    )
  end

  def create_a_cme_user_log
    CourseModuleElementUserLog.create!(
            course_module_element_id: @course_module_element.id,
            user_id: current_user.try(:id),
            session_guid: current_session_guid,
            element_completed: false,
            time_taken_in_seconds: 0,
            quiz_score_actual: nil,
            quiz_score_potential: nil,
            is_video: true,
            is_quiz: false,
            course_module_id: @course_module_element.course_module_id,
            corporate_customer_id: nil,
            course_module_jumbo_quiz_id: nil,
            is_jumbo_quiz: false
    )
  end

  def set_up_quiz
    @course_module_element_user_log = CourseModuleElementUserLog.new(
            session_guid: current_session_guid,
            course_module_id: @course_module_element.course_module_id,
            course_module_element_id: @course_module_element.id,
            is_quiz: true,
            user_id: current_user.try(:id)
    )
    @number_of_questions = @course_module_element.course_module_element_quiz.number_of_questions

    @number_of_questions.times do
      @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
    end

    all_easy_ids = @course_module_element.course_module_element_quiz.easy_ids
    all_medium_ids = @course_module_element.course_module_element_quiz.medium_ids
    all_difficult_ids = @course_module_element.course_module_element_quiz.difficult_ids
    @easy_ids = all_easy_ids.sample(@number_of_questions)
    @medium_ids = all_medium_ids.sample(@number_of_questions)
    @difficult_ids = all_difficult_ids.sample(@number_of_questions)
    @quiz_questions = QuizQuestion.includes(:quiz_contents).find(@easy_ids + @medium_ids + @difficult_ids)
    @enough_questions = @course_module_element.course_module_element_quiz.enough_questions? || current_user.try(:admin?)
    @first_attempt = @course_module_element_user_log.recent_attempts == 0
  end

  def set_up_jumbo_quiz
    @course_module_element_user_log = CourseModuleElementUserLog.new(
            session_guid: current_session_guid,
            course_module_id: @course_module.id,
            course_module_element_id: nil,
            course_module_jumbo_quiz_id: @course_module_jumbo_quiz.id,
            is_jumbo_quiz: true,
            user_id: current_user.try(:id)
    )
    @number_of_questions = @course_module_jumbo_quiz.total_number_of_questions

    @number_of_questions.times do
      @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
    end

    all_questions = QuizQuestion.where(course_module_element_id: @course_module.course_module_element_ids)
    all_easy_ids = all_questions.all_easy.map(&:id)
    all_medium_ids = all_questions.all_medium.map(&:id)
    all_difficult_ids = all_questions.all_difficult.map(&:id)
    @easy_ids = all_easy_ids.sample(@number_of_questions)
    @medium_ids = all_medium_ids.sample(@number_of_questions)
    @difficult_ids = all_difficult_ids.sample(@number_of_questions)
    @quiz_questions = QuizQuestion.find(@easy_ids + @medium_ids + @difficult_ids)
    @enough_questions = @quiz_questions.size >= @course_module_jumbo_quiz.total_number_of_questions || current_user.try(:admin?)
    Rails.logger.debug "DEBUG: recent_attempts=#{@course_module_element_user_log.recent_attempts.length}"
    @first_attempt = @course_module_element_user_log.recent_attempts.length == 0
  end

end
