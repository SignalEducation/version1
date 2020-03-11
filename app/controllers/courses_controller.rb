# frozen_string_literal: true

class CoursesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create_video_user_log video_watched_data]
  before_action :logged_in_required
  before_action :check_permission, only: %i[show show_constructed_response]

  def show
    @vimeo_as_main = vimeo_as_main?
    @subject_course_user_log = current_user.subject_course_user_logs.for_subject_course(@course.id).last if current_user.subject_course_user_logs.any?
    @course_section_user_log = @subject_course_user_log.course_section_user_logs.where(course_section_id: @course_section.id).last if @subject_course_user_log
    @student_exam_track = @course_section_user_log.student_exam_tracks.where(course_module_id: @course_module.id).last if @course_section_user_log
    @group = @course.group

    if @course_module_element.is_quiz
      set_up_quiz
    elsif @course_module_element.is_constructed_response
      set_up_constructed_response_start_screen
    end
  end

  def create
    # Create course_module_element_user_log for QUIZ from params sent in from previously initiated CMEUL record that was not saved
    @course_module_element_user_log = CourseModuleElementUserLog.new(allowed_params)
    @course_module_element_user_log.session_guid = current_session_guid

    @course_module_element = @course_module_element_user_log.course_module_element
    @course_module = @course_module_element_user_log.course_module
    @course = @course_module.subject_course
    @group = @course.group
    @valid_subscription = current_user.active_subscriptions_for_exam_body(@group.exam_body_id).all_valid.first
    @course_module_element_user_log.subject_course_id = @course.id
    @results = true

    if @course_module_element_user_log.save
      pass_rate = @course_module_element.course_module.subject_course.quiz_pass_rate ? @course_module_element.course_module.subject_course.quiz_pass_rate : 65
      percentage_score = @course_module_element_user_log.quiz_score_actual || 0

      @pass = percentage_score >= pass_rate ? 'Pass' : 'Fail'

      if @course_module && @course_module_element && @course_module_element_user_log
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
  end

  def video_watched_data
    cme                = CourseModuleElement.find(params[:cme_id])
    video_cme_user_log = CourseModuleElementUserLog.find(params[:video_log_id])

    respond_to do |format|
      format.json do
        if video_cme_user_log.update(element_completed: true,
                                     time_taken_in_seconds: cme&.duration&.to_i)
          render json: {}, status: :ok
        else
          render json: { video_log_id: video_cme_user_log.errors.messages }, status: :error
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Invalid video_log_id' }, status: :ok
  end

  def create_video_user_log
    course_module_element = CourseModuleElement.find(params[:course][:cmeId])
    video_cme_user_log    = CourseModuleElementUserLog.new(
      course_module_element_id: course_module_element.id,
      user_id: current_user.try(:id),
      session_guid: current_session_guid,
      element_completed: false,
      time_taken_in_seconds: 0,
      is_video: true,
      is_quiz: false,
      course_module_id: course_module_element.course_module_id,
      course_section_id: course_module_element.course_module.course_section_id,
      subject_course_id: course_module_element.course_module.course_section.subject_course_id,
      subject_course_user_log_id: params[:course][:scul_id].presence,
      course_section_user_log_id: params[:course][:csul_id].presence,
      student_exam_track_id: params[:course][:set_id].presence
    )

    respond_to do |format|
      format.json do
        if video_cme_user_log.save
          ab_finished(:user_onboarding) unless Rails.env.test?
          render json: { video_log_id: video_cme_user_log.id }, status: :ok
        else
          render json: { video_log_id: video_cme_user_log.errors.messages }, status: :error
        end
      end
    end
  end

  def show_constructed_response
    if @course_module&.active_children
      @course_module_element = @course_module.children.find_by(name_url: params[:course_module_element_name_url])
      current_user.non_student_user? && !@course_module_element.active ? (@preview_mode = true) : (@preview_mode = false)

      # CME name is not in the seo title because it is html_safe
      seo_title_maker("#{@course_module.name} - #{@course.name}", @course_module_element.try(:description), @course_module_element.try(:seo_no_index))

      if @course_module_element.is_constructed_response
        if params[:course_module_element_user_log_id]
          set_up_previous_constructed_response
        else
          set_up_new_constructed_response
        end

      end
      @footer = false
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
      # update_columns ?? to stop callback chain will be called on final submit
      if @course_module_element_user_log.update_attributes(constructed_response_allowed_params)
        format.json { render json: @course_module_element_user_log, status: :created }
      else
        format.json { render json: @course_module_element_user_log.errors, status: :unprocessable_entity }
      end
    end
  end

  def submit_constructed_response_user_log
    @course_module_element_user_log = CourseModuleElementUserLog.find(params[:cmeul_id])
    @subject_course_user_log = @course_module_element_user_log.subject_course_user_log

    @constructed_response_attempt = @course_module_element_user_log.constructed_response_attempt
    @constructed_response_attempt.update_attributes(status: 'Completed')

    @course_module_element_user_log.update_attributes(element_completed: true)

    redirect_to course_special_link(@course_module_element_user_log.course_module_element, @subject_course_user_log)
  end

  private

  def allowed_params
    params.require(:course_module_element_user_log).permit(
      :preview_mode,
      :subject_course_id,
      :student_exam_track_id,
      :subject_course_user_log_id,
      :course_section_id,
      :course_section_user_log_id,
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
      constructed_response_attempt_attributes: [
        :id,
        :constructed_response_id,
        :scenario_id,
        :course_module_element_id,
        :user_id,
        :original_scenario_text_content,
        :user_edited_scenario_text_content,
        :scratch_pad_text,
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
      course_module_element_id: @course_module_element.id,
      course_module_id: @course_module_element.course_module_id,
      course_section_id: @course_module_element.course_module.course_section_id,
      subject_course_id: @course_module_element.course_module.subject_course_id,
      subject_course_user_log_id: @subject_course_user_log.try(:id),
      course_section_user_log_id: @course_section_user_log.try(:id),
      student_exam_track_id: @student_exam_track.try(:id),
      is_quiz: true,
      is_video: false,
      user_id: current_user.try(:id)
    )
    @number_of_questions = @course_module_element.course_module_element_quiz.number_of_questions

    @number_of_questions.times do
      @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
    end

    @strategy = @course_module_element.course_module_element_quiz.question_selection_strategy

    if @strategy == 'random'
      all_ids_random = @course_module_element.course_module_element_quiz.all_ids_random
      @all_ids = all_ids_random.sample(@number_of_questions)
    else
      all_ids_ordered = @course_module_element.course_module_element_quiz.all_ids_ordered
      @all_ids = all_ids_ordered[0..@number_of_questions]
    end

    @quiz_questions = QuizQuestion.includes(:quiz_contents).find(@all_ids)
    @mathjax_required = true
  end

  def set_up_constructed_response_start_screen
    #Order by most recently updated_at
    @course_module_element_user_logs = @subject_course_user_log.course_module_element_user_logs.for_course_module_element(@course_module_element.id).reverse[0...8] if @subject_course_user_log
  end

  def set_up_new_constructed_response
    @mathjax_required = true
    @time_allowed = @course_module_element.constructed_response.time_allowed
    @constructed_response = @course_module_element.constructed_response
    @all_questions = @constructed_response.scenario.scenario_questions.all_in_order
    @all_question_ids = @constructed_response.scenario.scenario_questions.all_in_order.map(&:id)
    @subject_course_user_log = current_user.subject_course_user_logs.for_subject_course(@course.id).last if current_user.subject_course_user_logs.any?
    @course_section_user_log = @subject_course_user_log.course_section_user_logs.where(course_section_id: @course_section.id).last if @subject_course_user_log
    @student_exam_track = @course_section_user_log.student_exam_tracks.where(course_module_id: @course_module.id).last if @course_section_user_log

    #Creates CONSTRUCTED_RESPONSE log when page renders
    @course_module_element_user_log = CourseModuleElementUserLog.create!(
      preview_mode: @preview_mode,
      session_guid: current_session_guid,
      course_module_id: @course_module_element.course_module_id,
      course_section_id: @course_module_element.course_module.course_section_id,
      subject_course_id: @course_module_element.course_module.course_section.subject_course_id,
      subject_course_user_log_id: @preview_mode ? nil : @subject_course_user_log.try(:id),
      course_section_user_log_id: @preview_mode ? nil : @course_section_user_log.try(:id),
      student_exam_track_id: @preview_mode ? nil : @student_exam_track.try(:id),
      course_module_element_id: @course_module_element.id,
      time_taken_in_seconds: @course_module_element.estimated_time_in_seconds,
      is_quiz: false,
      is_video: false,
      is_constructed_response: true,
      user_id: current_user.id
    )
    @constructed_response_attempt = ConstructedResponseAttempt.create!(
      constructed_response_id: @constructed_response.id,
      scenario_id: @constructed_response.scenario.id,
      course_module_element_id: @constructed_response.course_module_element_id,
      course_module_element_user_log_id: @course_module_element_user_log.id,
      user_id: current_user.id,
      status: 'Incomplete',
      original_scenario_text_content: @constructed_response.scenario.text_content,
      user_edited_scenario_text_content: @constructed_response.scenario.text_content,
      guid: ApplicationController.generate_random_code(6),
      scratch_pad_text: 'You can write notes here...'
    )
    @all_questions.each do |scenario_question|
      scenario_question_attempt = ScenarioQuestionAttempt.create!(
        constructed_response_attempt_id: @constructed_response_attempt.id,
        user_id: current_user.id,
        scenario_question_id: scenario_question.id,
        status: 'Unseen',
        flagged_for_review: false,
        sorting_order: scenario_question.sorting_order,
        original_scenario_question_text: scenario_question.text_content,
        user_edited_scenario_question_text: scenario_question.text_content
      )

      scenario_question.scenario_answer_templates.each do |scenario_answer_template|
        text_content = scenario_answer_template.spreadsheet_editor? ? scenario_answer_template.spreadsheet_editor_content : scenario_answer_template.text_editor_content
        ScenarioAnswerAttempt.create!(
          scenario_question_attempt_id: scenario_question_attempt.id,
          user_id: current_user.id,
          scenario_answer_template_id: scenario_answer_template.id,
          original_answer_template_text: text_content,
          user_edited_answer_template_text: text_content,
          editor_type: scenario_answer_template.editor_type,
          sorting_order: scenario_answer_template.sorting_order
        )
      end
    end

    @all_scenario_question_attempt = @constructed_response_attempt.scenario_question_attempts.all_in_order
    @all_scenario_question_attempt_ids = @constructed_response_attempt.scenario_question_attempts.all_in_order.map(&:id)
  end

  def set_up_previous_constructed_response
    @mathjax_required = true
    @constructed_response = @course_module_element.constructed_response
    @time_allowed = @constructed_response.time_allowed
    @all_question_ids = @constructed_response.scenario.scenario_questions.all_in_order.map(&:id)

    @subject_course_user_log = current_user.subject_course_user_logs.for_subject_course(@course.id).last if current_user.subject_course_user_logs.any?
    @course_section_user_log = @subject_course_user_log.course_section_user_logs.where(course_section_id: @course_section.id).last if @subject_course_user_log
    @student_exam_track = @course_section_user_log.student_exam_tracks.where(course_module_id: @course_module.id).last if @course_section_user_log

    @course_module_element_user_log = CourseModuleElementUserLog.find(params[:course_module_element_user_log_id])
    @constructed_response_attempt = @course_module_element_user_log.constructed_response_attempt

    @all_scenario_question_attempt = @constructed_response_attempt.scenario_question_attempts.all_in_order
    @all_scenario_question_attempt_ids = @constructed_response_attempt.scenario_question_attempts.all_in_order.map(&:id)
  end

  protected

  def check_permission
    @course = SubjectCourse.find_by(name_url: params[:subject_course_name_url])
    @group = @course.group
    @course_section = @course.course_sections.all_active.find_by(name_url: params[:course_section_name_url]) if @course
    @course_module = @course_section.course_modules.all_active.find_by(name_url: params[:course_module_name_url]) if @course_section
    @course_module_element = @course_module.course_module_elements.all_active.find_by(name_url: params[:course_module_element_name_url]) if @course_module
    @subject_course_user_log = current_user.subject_course_user_logs.for_subject_course(@course.id).all_in_order.last
    @valid_subscription = current_user.active_subscriptions_for_exam_body(@group.exam_body_id).all_valid.first
    permission = @course_module_element&.available_to_user(current_user, @valid_subscription, @subject_course_user_log)

    return if @course_module_element && permission && permission[:view]

    if permission && permission[:reason]
      redirect_to library_course_url(@group.name_url, @course.name_url, anchor: permission[:reason])
    else
      flash[:warning] = 'Sorry, you are not permitted to access that content.'
      redirect_to library_special_link(@course)
    end
  end
end
