class CoursesController < ApplicationController

  skip_after_filter :intercom_rails_auto_include, only: :show_constructed_response
  before_action :logged_in_required
  before_action :check_permission, only: [:show, :show_constructed_response]

  def show
    if @course_module && @course_module.active_children
      @course_module_element = @course_module.active_children.find_by(name_url: params[:course_module_element_name_url])
      @course_module_element ||= @course_module.active_children.all_in_order.first

      #CME name is not in the seo title because it is html_safe
      seo_title_maker("#{@course_module.name} - #{@course.name}", @course_module_element.try(:description), @course_module_element.try(:seo_no_index))

      if @course_module_element.is_quiz
        set_up_quiz
      elsif @course_module_element.is_constructed_response
        set_up_constructed_response_start_screen
      end
    else
      ## The URL params are wrong ##
      flash[:warning] = t('controllers.courses.show.warning')
      Rails.logger.warn "WARN: CoursesController#show failed to find content. Params: #{request.filtered_parameters}."
      redirect_to library_special_link(@course)
    end
  end

  def create
    # Create course_module_element_user_log for QUIZ from params sent in from previously initiated CMEUL record that was not saved
    if current_user
      @course_module_element_user_log = CourseModuleElementUserLog.new(allowed_params)
      @course_module_element_user_log.session_guid = current_session_guid

      @course_module_element = @course_module_element_user_log.course_module_element
      @course_module = @course_module_element_user_log.course_module
      @course_module_element_user_log.subject_course_id = @course_module.subject_course_id
      @results = true
      if @course_module_element_user_log.save
        pass_rate = @course_module_element.course_module.subject_course.quiz_pass_rate ? @course_module_element.course_module.subject_course.quiz_pass_rate : 65
        percentage_score = @course_module_element_user_log.quiz_score_actual || 0

        @pass = percentage_score >= pass_rate ? 'Pass' : 'Fail'

        if params[:demo_mode] == 'yes'
          redirect_to course_module_element_path(@course_module_element_user_log.course_module_element)
        elsif @course_module && @course_module_element && @course_module_element_user_log
          render :show
        else
          redirect_to library_url
        end
        @mathjax_required = true

      else
        # it did not save
        Rails.logger.error "ERROR: CoursesController#create: Failed to save. CME-UserLog.inspect #{@course_module_element_user_log.errors.inspect}."
        flash[:error] = I18n.t('controllers.courses.create.flash.error')
        redirect_to library_special_link(@course_module.parent)
      end

    else
      redirect_to library_url
    end
  end

  def video_watched_data
    respond_to do |format|
      format.json {
        video_cme_user_log = CourseModuleElementUserLog.find_by_id(params[:course][:videoLogId])
        if video_cme_user_log
          cme = video_cme_user_log.course_module_element
          video_cme_user_log.element_completed = true
          video_cme_user_log.time_taken_in_seconds = cme.duration.to_i if cme.duration
          video_cme_user_log.save
          #Triggers Update Callbacks
        end
        render json: {}, status: :ok
      }
    end
  end

  def create_video_user_log
    #Create Video Log upon vimeo player play event sent by JSON, later updated by another JSON request to video_watched_data method
    respond_to do |format|
      format.json {
        course_module_element = CourseModuleElement.find(params[:course][:cmeId])
        param_id = params[:course][:set_id]
        if param_id && !param_id.empty?
          student_exam_track_id = param_id
        elsif param_id && param_id.empty?
          student_exam_track_id = nil
        else
          student_exam_track_id = nil
        end

        if course_module_element
          @video_cme_user_log = CourseModuleElementUserLog.create!(
              course_module_element_id: course_module_element.id,
              user_id: current_user.try(:id),
              session_guid: current_session_guid,
              element_completed: false,
              time_taken_in_seconds: 0,
              is_video: true,
              is_quiz: false,
              course_module_id: course_module_element.course_module_id,
              subject_course_id: course_module_element.course_module.subject_course_id,
              subject_course_user_log_id: params[:course][:scul_id],
              student_exam_track_id: student_exam_track_id
          )
        end
        data = {video_log_id: @video_cme_user_log.id}
        render json: data, status: :ok
      }
    end

  end

  def show_constructed_response
    if @course_module && @course_module.active_children
      @course_module_element = @course_module.active_children.find_by(name_url: params[:course_module_element_name_url])
      @course_module_element ||= @course_module.active_children.all_in_order.first

      #CME name is not in the seo title because it is html_safe
      seo_title_maker("#{@course_module.name} - #{@course.name}", @course_module_element.try(:description), @course_module_element.try(:seo_no_index))

      if @course_module_element.is_constructed_response
        if params[:course_module_element_user_log_id]
          set_up_previous_constructed_response
        else
          set_up_new_constructed_response
        end

      end

    else
      ## The URL params are wrong ##
      flash[:warning] = t('controllers.courses.show.warning')
      Rails.logger.warn "WARN: CoursesController#show failed to find content. Params: #{request.filtered_parameters}."
      redirect_to library_special_link(@course)
    end
  end

  def update_constructed_response_user_log
    @course_module_element_user_log = CourseModuleElementUserLog.find(params[:course_module_element_user_log][:id])

    respond_to do |format|
      if @course_module_element_user_log.update_attributes(constructed_response_allowed_params)
        format.json { render json: @course_module_element_user_log, status: :created }
      else
        format.json { render json: @course_module_element_user_log.errors, status: :unprocessable_entity }
      end

    end
  end

  private

  def allowed_params
    params.require(:course_module_element_user_log).permit(
            :subject_course_id,
            :student_exam_track_id,
            :subject_course_user_log_id,
            :course_module_id,
            :course_module_element_id,
            :user_id,
            :time_taken_in_seconds,
            quiz_attempts_attributes: [
                    :id,
                    :user_id,
                    :quiz_question_id,
                    :quiz_answer_id,
                    :answer_array
            ]
    )
  end

  def constructed_response_allowed_params
    params.require(:course_module_element_user_log).permit(
            :subject_course_id,
            :student_exam_track_id,
            :subject_course_user_log_id,
            :course_module_id,
            :course_module_element_id,
            :user_id,
            :time_taken_in_seconds,
            constructed_response_attempt_attributes: [
                    :id,
                    :constructed_response_id,
                    :scenario_id,
                    :course_module_element_id,
                    :user_id,
                    :original_scenario_text_content,
                    :user_edited_scenario_text_content,
                    scenario_question_attempts_attributes: [
                        :id,
                        :constructed_response_attempt_id,
                        :user_id,
                        :scenario_question_id,
                        :status,
                        :flagged_for_review,
                        :original_scenario_question_text,
                        :user_edited_scenario_question_text,
                        scenario_answer_attempts_attributes: [
                            :id,
                            :scenario_question_attempt_id,
                            :user_id,
                            :scenario_answer_template_id,
                            :original_answer_template_text,
                            :user_edited_answer_template_text,
                            :editor_type
                        ]

                    ]
            ]
    )
  end

  def set_up_quiz
    #Creates QUIZ log when page renders but does not save log, data is sent as params to create method where a new CMEUL is initiated and saved
    @course_module_element_user_log = CourseModuleElementUserLog.new(
            session_guid: current_session_guid,
            course_module_id: @course_module_element.course_module_id,
            subject_course_id: @course_module_element.course_module.subject_course_id,
            subject_course_user_log_id: @subject_course_user_log.id,
            student_exam_track_id: @student_exam_track.try(:id),
            course_module_element_id: @course_module_element.id,
            is_quiz: true,
            is_video: false,
            user_id: current_user.try(:id))
    @number_of_questions = @course_module_element.course_module_element_quiz.number_of_questions

    @number_of_questions.times do
      @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
    end

    @strategy = @course_module_element.course_module_element_quiz.question_selection_strategy

    if @strategy == 'random'
      all_ids_random = @course_module_element.course_module_element_quiz.all_ids_random
      @all_ids = all_ids_random.sample(@number_of_questions)
      @quiz_questions = QuizQuestion.includes(:quiz_contents).find(@all_ids)
    else
      all_ids_ordered = @course_module_element.course_module_element_quiz.all_ids_ordered
      @all_ids = all_ids_ordered[0..@number_of_questions]
      @quiz_questions = QuizQuestion.includes(:quiz_contents).find(@all_ids)
    end
    @mathjax_required = true
  end

  def set_up_constructed_response_start_screen
    #Order by most recently updated_at
    @course_module_element_user_logs = @subject_course_user_log.course_module_element_user_logs.for_course_module_element(@course_module_element.id).reverse[0...5]

  end

  def set_up_new_constructed_response
    @mathjax_required = true
    @time_allowed = @course_module_element.constructed_response.time_allowed
    @constructed_response = @course_module_element.constructed_response
    @all_questions = @constructed_response.scenario.scenario_questions
    @all_question_ids = @constructed_response.scenario.scenario_questions.map(&:id)

    #Creates CONSTRUCTED_RESPONSE log when page renders
    @course_module_element_user_log = CourseModuleElementUserLog.create(
        session_guid: current_session_guid,
        course_module_id: @course_module_element.course_module_id,
        subject_course_id: @course_module_element.course_module.subject_course_id,
        subject_course_user_log_id: @subject_course_user_log.id,
        student_exam_track_id: @student_exam_track.try(:id),
        course_module_element_id: @course_module_element.id,
        is_quiz: false,
        is_video: false,
        is_constructed_response: true,
        user_id: current_user.id
    )
    @constructed_response_attempt = ConstructedResponseAttempt.create(
        constructed_response_id: @constructed_response.id,
        scenario_id: @constructed_response.scenario.id,
        course_module_element_id: @constructed_response.course_module_element_id,
        course_module_element_user_log_id: @course_module_element_user_log.id,
        user_id: current_user.id,
        original_scenario_text_content: @constructed_response.scenario.text_content,
        user_edited_scenario_text_content: @constructed_response.scenario.text_content
    )
    @all_questions.each do |scenario_question|
      scenario_question_attempt = ScenarioQuestionAttempt.create(
          constructed_response_attempt_id: @constructed_response_attempt.id,
          user_id: current_user.id,
          scenario_question_id: scenario_question.id,
          status: 'Unseen',
          flagged_for_review: false,
          original_scenario_question_text: scenario_question.text_content,
          user_edited_scenario_question_text: scenario_question.text_content
      )

      scenario_question.scenario_answer_templates.each do |scenario_answer_template|

        text_content = scenario_answer_template.spreadsheet_editor? ? scenario_answer_template.spreadsheet_editor_content : scenario_answer_template.text_editor_content

        scenario_answer_attempt = ScenarioAnswerAttempt.create(
            scenario_question_attempt_id: scenario_question_attempt.id,
            user_id: current_user.id,
            scenario_answer_template_id: scenario_answer_template.id,
            original_answer_template_text: text_content,
            user_edited_answer_template_text: text_content,
            editor_type: scenario_answer_template.editor_type
        )


      end
    end
    @all_scenario_question_attempt = @constructed_response_attempt.scenario_question_attempts
    @all_scenario_question_attempt_ids = @constructed_response_attempt.scenario_question_attempts.map(&:id)

  end


  def set_up_previous_constructed_response
    @mathjax_required = true
    @constructed_response = @course_module_element.constructed_response
    @time_allowed = @constructed_response.time_allowed
    @all_question_ids = @constructed_response.scenario.scenario_questions.map(&:id)

    @course_module_element_user_log = CourseModuleElementUserLog.find(params[:course_module_element_user_log_id])
    @constructed_response_attempt = @course_module_element_user_log.constructed_response_attempt

    @all_scenario_question_attempt = @constructed_response_attempt.scenario_question_attempts
    @all_scenario_question_attempt_ids = @constructed_response_attempt.scenario_question_attempts.map(&:id)
  end

  protected

  def check_permission
    @course = SubjectCourse.find_by(name_url: params[:subject_course_name_url])
    @course_module = @course.course_modules.find_by(name_url: params[:course_module_name_url]) if @course

    if @course && @course_module && current_user && current_user.permission_to_see_content

      @active_enrollment = current_user.enrollments.all_active.all_not_expired.for_subject_course(@course.id).last
      if @active_enrollment
        @subject_course_user_log = @active_enrollment.subject_course_user_log
        @student_exam_track = @subject_course_user_log.student_exam_tracks.where(course_module_id: @course_module.id).last
      else
        flash[:warning] = 'Sorry, you are not permitted to access that content.'
        redirect_to root_url
      end
    else
      if current_user.expired_trial_user?
        flash[:warning] = 'Sorry, your free trial has expired. Please Upgrade to a paid subscription to continue'
        redirect_to new_subscription_url
      elsif current_user.current_subscription && current_user.canceled_member?
        flash[:warning] = 'Sorry, your Subscription is no longer valid. Please Upgrade to a valid subscription to continue'
        redirect_to new_subscription_url
      else
        flash[:warning] = 'Sorry, you are not permitted to access that content.'
        redirect_to root_url
      end
    end
  end

end
