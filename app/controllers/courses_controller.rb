class CoursesController < ApplicationController

  before_action :logged_in_required

  def show
    @mathjax_required = true
    @course = SubjectCourse.find_by(name_url: params[:subject_course_name_url])
    if @course
      if @course.corporate_customer_id
        if @course.restricted && (current_user.corporate_customer_id == nil || current_user.corporate_customer_id != @course.corporate_customer_id)
          redirect_to subscription_groups_url
        end
      end

      if @course
        @course_module = @course.course_modules.find_by(name_url: params[:course_module_name_url])
      end
      if @course_module
        @course_module_element = @course_module.course_module_elements.find_by(name_url: params[:course_module_element_name_url])
        @course_module_jumbo_quiz = @course_module.course_module_jumbo_quiz if @course_module && @course_module.course_module_jumbo_quiz.try(:name_url) == params[:course_module_element_name_url] && @course_module.course_module_jumbo_quiz.try(:active)
        @course_module_element ||= @course_module.try(:course_module_elements).try(:all_in_order).try(:all_active).try(:first) unless @course_module_jumbo_quiz

        #CME name is not in the seo title because it is html_safe and could have <b></b> tags
        seo_title_maker("#{@course_module.name} - #{@course.name}", @course_module_element.try(:description), @course_module_element.try(:seo_no_index))
      end


      if @course_module_element.nil? && @course_module.nil?

        @question_bank = @course.try(:question_bank)
        if @question_bank.nil?
          # The URL is out of date or wrong.
          flash[:warning] = t('controllers.courses.show.warning')
          Rails.logger.warn "WARN: CoursesController#show failed to find content. Params: #{request.filtered_parameters}."
          redirect_to library_special_link(@course)
        else
          set_up_question_bank

        end
      else
        # The URL worked out Okay
        reset_post_sign_up_redirect_path(library_special_link(@course_module.subject_course)) unless current_user
        if current_user
          #current_user.check_and_free_trial_status if current_user.individual_student?
          if @course_module_element.try(:is_quiz)
            set_up_quiz
          elsif @course_module_jumbo_quiz
            set_up_jumbo_quiz
          elsif @course_module_element.try(:is_video)
            @video_cme_user_log = create_a_cme_user_log if paywall_checkpoint
          end
        end
      end
      @paywall = paywall_checkpoint
    else
      flash[:warning] = t('controllers.courses.show.warning')
      Rails.logger.warn "WARN: CoursesController#show failed to find content. Params: #{request.filtered_parameters}."
      redirect_to subscription_groups_url
    end
  end

  def create
    # Create course_module_element_user_log for QUIZ from params sent in from previously initiated CMEUL record that was not saved
    if current_user
      @mathjax_required = true
      @course_module_element_user_log = CourseModuleElementUserLog.new(allowed_params)
      @course_module_element_user_log.session_guid = current_session_guid
      @course_module_element_user_log.corporate_customer_id = current_user.try(:corporate_customer_id)
      @course_module_element_user_log.element_completed = true
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
        redirect_to subscription_groups_url
      end
    else
      redirect_to subscription_groups_url
    end
  end

  def video_watched_data
    respond_to do |format|
      format.json {
        video_cme_user_log = CourseModuleElementUserLog.find_by_id(params[:course][:videoLogId])
        cme = video_cme_user_log.course_module_element
        if video_cme_user_log
          video_cme_user_log.element_completed = true
          video_cme_user_log.time_taken_in_seconds = cme.try(:duration)
          video_cme_user_log.save
          #Triggers Update Callbacks
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


  def create_a_cme_user_log
    #Creating Video Log upon loading video page, later updated by JSON request to video_watched_data method

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
            corporate_customer_id: current_user.try(:corporate_customer_id),
            course_module_jumbo_quiz_id: nil,
            is_jumbo_quiz: false,
            question_bank_id: nil,
            is_question_bank: false
    )
  end

  def set_up_quiz
    #Creates QUIZ log when page renders but does not save log, data is sent as params to create method where a new CMEUL is initiated and saved
    @course_module_element_user_log = CourseModuleElementUserLog.new(
            session_guid: current_session_guid,
            course_module_id: @course_module_element.course_module_id,
            course_module_element_id: @course_module_element.id,
            is_quiz: true,
            is_video: false,
            user_id: current_user.try(:id),
            corporate_customer_id: current_user.try(:corporate_customer_id)
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
            user_id: current_user.try(:id),
            corporate_customer_id: current_user.try(:corporate_customer_id)
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
        question_bank_id: @question_bank.try(:id),
        is_question_bank: true,
        user_id: current_user.try(:id),
        corporate_customer_id: current_user.try(:corporate_customer_id)
    )
    @number_of_questions = @question_bank.number_of_questions

    @number_of_questions.times do
      @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
    end

    @strategy = @question_bank.question_selection_strategy
    all_questions = QuizQuestion.where(subject_course_id: @question_bank.subject_course_id)
    final_quiz_quizzes = CourseModuleElementQuiz.all_for_final_quiz
    final_quiz_questions = all_questions.where(course_module_element_quiz_id: final_quiz_quizzes)

    all_ids = final_quiz_questions.map(&:id)

    @ids = all_ids.sample(@number_of_questions)
    @easy_ids = @ids
    @medium_ids = []
    @difficult_ids = []
    @all_ids = @easy_ids + @medium_ids + @difficult_ids
    @quiz_questions = QuizQuestion.find(@easy_ids + @medium_ids + @difficult_ids)
    @first_attempt = @course_module_element_user_log.recent_attempts.length == 0

  end

  protected

end
