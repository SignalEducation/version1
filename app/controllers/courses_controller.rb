class CoursesController < ApplicationController

  before_action :check_for_old_url_format, only: :show

  def show

    @mathjax_required = true
    institution = Institution.find_by(name_url: params[:institution_name_url])
    qualification = Qualification.find_by_name_url(params[:qualification_name_url])
    exam_level = qualification.exam_levels.find_by(name_url: params[:exam_level_name_url])
    @course_module = exam_level.course_modules.find_by(name_url: params[:course_module_name_url])
    if @course_module
      @course_module_element = @course_module.course_module_elements.find_by(name_url: params[:course_module_element_name_url])
      @course_module_jumbo_quiz = @course_module.course_module_jumbo_quiz if @course_module && @course_module.course_module_jumbo_quiz.try(:name_url) == params[:course_module_element_name_url] && @course_module.course_module_jumbo_quiz.try(:active)
      @course_module_element ||= @course_module.try(:course_module_elements).try(:all_in_order).try(:all_active).try(:first) unless @course_module_jumbo_quiz

      seo_title_maker("#{institution.short_name} - #{exam_level.name} - #{@course_module_element.try(:name)}", @course_module_element.try(:seo_description) || @course_module.try(:seo_description).to_s, @course_module_element.try(:seo_no_index) || @course_module.try(:seo_no_index))
    end

    if @course_module_element.nil? && @course_module.nil?

      @question_bank = QuestionBank.find_by_id(params[:course_module_name_url])
      set_up_question_bank

      # The URL is out of date or wrong.
      #@exam_section = params[:exam_section_name_url] == 'all' ?
            #nil :
            #ExamSection.find_by(name_url: params[:exam_section_name_url])
      #@exam_level = ExamLevel.find_by(name_url: params[:exam_level_name_url])
      #@qualification = Qualification.find_by(name_url: params[:qualification_name_url])
      #@institution = Institution.find_by(name_url: params[:institution_name_url])
      #@subject_area = SubjectArea.find_by(name_url: params[:subject_area_name_url])
      #flash[:warning] = t('controllers.courses.show.warning')
      #Rails.logger.warn "WARN: CoursesController#show failed to find content. Params: #{request.filtered_parameters}."
      #redirect_to library_special_link(@exam_section || @exam_level || @qualification || @institution || @subject_area || nil)
    else
      # The URL worked out Okay
      reset_post_sign_up_redirect_path(library_special_link(@course_module.exam_level)) unless current_user
      if @course_module_element.try(:is_quiz)
        set_up_quiz
      elsif @course_module_jumbo_quiz
        set_up_jumbo_quiz
      elsif @course_module_element.try(:is_video)
        @video_cme_user_log = create_a_cme_user_log if paywall_checkpoint(@course_module_element.my_position_among_siblings, false)
      end
    end
    @paywall = paywall_checkpoint(@course_module_element.try(:my_position_among_siblings) || 0, @course_module_jumbo_quiz.try(:id).to_i > 0)
  end

  def create # course_module_element_user_log and children
    @mathjax_required = true
    @course_module_element_user_log = CourseModuleElementUserLog.new(allowed_params)
    @course_module_element_user_log.session_guid = current_session_guid
    @course_module_element_user_log.element_completed = true
    @course_module_element_user_log.time_taken_in_seconds += Time.now.to_i if @course_module_element_user_log.time_taken_in_seconds.to_i != 0
    @course_module_element = @course_module_element_user_log.course_module_element
    @course_module_jumbo_quiz = @course_module_element_user_log.course_module_jumbo_quiz
    @question_bank = @course_module_element_user_log.question_bank
    @course_module = @course_module_element_user_log.course_module
    @results = true
    unless @course_module_element_user_log.save
      # it did not save
      Rails.logger.error "ERROR: CoursesController#create: Failed to save. CME-UserLog.inspect #{@course_module_element_user_log.errors.inspect}."
      flash[:error] = I18n.t('controllers.courses.create.flash.error')
    end
    if params[:demo_mode] == 'yes'
      redirect_to course_module_element_path(@course_module_element_user_log.course_module_element)
    elsif @question_bank || (@course_module && (@course_module_element || @course_module_jumbo_quiz))
      render :show
    else
      redirect_to library_url
    end
  end

  def video_watched_data
    respond_to do |format|
      format.json {
        video_cme_user_log = CourseModuleElementUserLog.find_by_id(params[:course][:videoLogId])
        if video_cme_user_log
          video_cme_user_log.seconds_watched += params[:course][:position]
          video_cme_user_log.element_completed = video_cme_user_log.seconds_watched >= params[:course][:duration].to_i
          video_cme_user_log.save
        end
        render json: {}, status: :ok
      }
    end
  end

  private

  def allowed_params
    params.require(:course_module_element_user_log).permit(
            :course_module_id,
            :course_module_element_id,
            :course_module_jumbo_quiz_id,
            :question_bank_id,
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
                    :quiz_answer_id,
                    :answer_array
            ]
    )
  end

  def check_for_old_url_format
    if params[:id].to_i > 0
      it = ImportTracker.where(old_model_name: 'course', old_model_id: params[:id].to_i, new_model_name: 'exam_section').first
      if it
        redirect_to library_special_link(ExamSection.find(it.new_model_id))
        false
      else
        true
      end
    else
      true
    end
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
            is_jumbo_quiz: false,
            question_bank_id: nil,
            is_question_bank: false
    )
  end

  def set_up_quiz
    @course_module_element_user_log = CourseModuleElementUserLog.new(
            session_guid: current_session_guid,
            course_module_id: @course_module_element.course_module_id,
            course_module_element_id: @course_module_element.id,
            is_quiz: true,
            is_video: false,
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
    @all_ids = @easy_ids + @medium_ids + @difficult_ids
    @strategy = @course_module_element.course_module_element_quiz.question_selection_strategy
    @quiz_questions = QuizQuestion.includes(:quiz_contents).find(@easy_ids + @medium_ids + @difficult_ids)
    @first_attempt = @course_module_element_user_log.recent_attempts.count == 0
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

    @strategy = @course_module_jumbo_quiz.course_module.course_module_elements.all_quizzes.first.course_module_element_quiz.question_selection_strategy

    all_questions = QuizQuestion.where(course_module_element_id: @course_module.course_module_elements.all.ids)
    all_easy_ids = all_questions.all_easy.map(&:id)
    all_medium_ids = all_questions.all_medium.map(&:id)
    all_difficult_ids = all_questions.all_difficult.map(&:id)
    @easy_ids = all_easy_ids.sample(@number_of_questions)
    @medium_ids = all_medium_ids.sample(@number_of_questions)
    @difficult_ids = all_difficult_ids.sample(@number_of_questions)
    @all_ids = @easy_ids + @medium_ids + @difficult_ids
    @quiz_questions = QuizQuestion.find(@easy_ids + @medium_ids + @difficult_ids)
    Rails.logger.debug "DEBUG: recent_attempts=#{@course_module_element_user_log.recent_attempts.length}"
    @first_attempt = @course_module_element_user_log.recent_attempts.length == 0
  end

  def set_up_question_bank

    @course_module_element_user_log = CourseModuleElementUserLog.new(
        session_guid: current_session_guid,
        course_module_id: nil,
        course_module_element_id: nil,
        question_bank_id: @question_bank.id,
        is_question_bank: true,
        user_id: current_user.try(:id)
    )
    @number_of_questions = @question_bank.number_of_questions
    @number_of_easy_questions = @question_bank.easy_questions.to_i
    @number_of_medium_questions = @question_bank.medium_questions.to_i
    @number_of_hard_questions = @question_bank.hard_questions.to_i

    @number_of_questions.times do
      @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
    end

    @strategy = @question_bank.question_selection_strategy
    all_questions = QuizQuestion.where(exam_level_id: @question_bank.exam_level_id)
    all_easy_ids = all_questions.all_easy.map(&:id)
    all_medium_ids = all_questions.all_medium.map(&:id)
    all_difficult_ids = all_questions.all_difficult.map(&:id)
    @easy_ids = all_easy_ids.sample(@number_of_easy_questions)
    @medium_ids = all_medium_ids.sample(@number_of_medium_questions)
    @difficult_ids = all_difficult_ids.sample(@number_of_hard_questions)
    @all_ids = @easy_ids + @medium_ids + @difficult_ids
    @quiz_questions = QuizQuestion.find(@easy_ids + @medium_ids + @difficult_ids)
    @first_attempt = @course_module_element_user_log.recent_attempts.length == 0

  end

end
