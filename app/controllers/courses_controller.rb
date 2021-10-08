# frozen_string_literal: true

class CoursesController < ApplicationController
  include ApplicationHelper

  skip_before_action :verify_authenticity_token, only: %i[create_video_user_log video_watched_data]
  before_action :logged_in_required
  before_action :student_sidebar_layout
  before_action :check_permission, only: %i[show show_constructed_response]

  def show
    @vimeo_as_main = vimeo_as_main?
    @course_log = current_user.course_logs.for_course(@course.id).last if current_user.course_logs.any?
    @course_section_log = @course_log.course_section_logs.where(course_section_id: @course_section.id).last if @course_log
    @course_lesson_log = @course_section_log.course_lesson_logs.where(course_lesson_id: @course_lesson.id).last if @course_section_log
    @group = @course.group
    @course_step_index = @course_lesson.active_children.find_index { |item| item.id == @course_step.id } + 1
    @index_order = @course_step_index.to_s + '/' + @course_lesson.active_children.count.to_s
    @previous_completion_count = @course_lesson_log.course_step_logs.for_user(current_user.id).for_course_step(@course_step.id).all_completed.count if @course_lesson_log&.course_step_logs

    if @course_step.is_quiz
      set_up_quiz
    elsif @course_step.is_note
      set_up_notes
    elsif @course_step.is_practice_question
      set_up_practice_question
    elsif @course_step.is_constructed_response
      set_up_constructed_response_start_screen
    end
  end

  def update
    @course_step_log =
      CourseStepLog.
        includes(quiz_attempts: { quiz_question: %i[quiz_contents quiz_solutions]}).
        find(params[:course_step_log][:id])

    set_up_course_step_log
    if @course_step_log.save
      course_pass_rate = @course_step.course_lesson.course.quiz_pass_rate || 75
      pass_rate        = @course_step.course_lesson.free ? 25 : course_pass_rate
      percentage_score = @course_step_log.quiz_score_actual || 0

      @pass = percentage_score >= pass_rate ? 'Pass' : 'Fail'
      @course_step_index = @course_lesson.active_children.find_index { |item| item.name == @course_step.name } + 1
      @index_order = @course_step_index.to_s + '/' + @course_lesson.active_children.count.to_s
      @quiz_score = @course_step_log.quiz_score_actual.to_s + '%'

      previous_scores = @course_step_log.course_lesson_log&.course_step_logs&.for_user(current_user.id)&.for_course_step(@course_step.id)&.all_completed&.map(&:quiz_score_actual)
      @previous_best_score = previous_scores.any? ? previous_scores.max.to_s + '%' : nil
      previous_passes = @course_step_log.course_lesson_log&.course_step_logs&.for_user(current_user.id)&.for_course_step(@course_step.id)&.all_completed&.map(&:quiz_result)
      @previously_passed = previous_passes.include?('passed').to_s

      if @course_lesson && @course_step && @course_step_log
        render :show
      else
        redirect_to library_url
      end
      @mathjax_required = true

    else
      # it did not save
      Rails.logger.error "ERROR: CoursesController#update: Failed to save. CME-UserLog.inspect #{@course_step_log.errors.inspect}."
      flash[:error] = I18n.t('controllers.courses.create.flash.error')
      redirect_to library_special_link(@course_lesson.parent)
    end
  end

  def video_watched_data
    cme                = CourseStep.find(params[:cme_id])
    video_cme_user_log = CourseStepLog.find(params[:video_log_id])
    update_params      = { element_completed: true, time_taken_in_seconds: cme&.duration&.to_i }

    respond_to do |format|
      format.json do
        if video_cme_user_log.update(update_params)
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
    course_step = CourseStep.find(params[:cmeId])
    video_cme_user_log = CourseStepLog.new(
      course_step_id: course_step.id,
      user_id: current_user.try(:id),
      session_guid: current_session_guid,
      element_completed: false,
      time_taken_in_seconds: 0,
      is_video: true,
      is_quiz: false,
      course_lesson_id: course_step.course_lesson_id,
      course_section_id: course_step.course_lesson.course_section_id,
      course_id: course_step.course_lesson.course_section.course_id,
      course_log_id: params[:scul_id].presence,
      course_section_log_id: params[:csul_id].presence,
      course_lesson_log_id: params[:set_id].presence
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
    if @course_lesson&.active_children
      @course_step = @course_lesson.children.find_by(name_url: params[:course_step_name_url])
      current_user.non_student_user? && !@course_step.active ? (@preview_mode = true) : (@preview_mode = false)

      @course_step_index = @course_lesson.active_children.find_index { |item| item.name == @course_step.name } + 1

      # CME name is not in the seo title because it is html_safe
      seo_title_maker("#{@course_lesson.name} - #{@course.name}", @course_step.try(:description), @course_step.try(:seo_no_index))

      if @course_step.is_constructed_response
        if params[:course_step_log_id]
          set_up_previous_constructed_response
        else
          set_up_new_constructed_response
        end

      end
      @footer = false
      @chat   = false
    else
      ## The URL params are wrong ##
      flash[:warning] = t('controllers.courses.show.warning')
      Rails.logger.warn "WARN: CoursesController#show failed to find content. Params: #{request.filtered_parameters}."
      redirect_to library_special_link(@course)
    end
  end

  def update_constructed_response_user_log
    @course_step_log = CourseStepLog.find(params[:course_step_log][:id])
    respond_to do |format|
      # update_columns ?? to stop callback chain will be called on final submit
      if @course_step_log.update_attributes(constructed_response_allowed_params)
        format.json { render json: @course_step_log, status: :created }
      else
        format.json { render json: @course_step_log.errors, status: :unprocessable_entity }
      end
    end
  end

  def submit_constructed_response_user_log
    @course_step_log = CourseStepLog.find(params[:cmeul_id])
    @course_log = @course_step_log.course_log

    @constructed_response_attempt = @course_step_log.constructed_response_attempt
    @constructed_response_attempt.update_attributes(status: 'Completed')

    @course_step_log.update_attributes(element_completed: true)

    redirect_to course_special_link(@course_step_log.course_step, @course_log)
  end

  def update_quiz_attempts
    @course_step_log = CourseStepLog.find(params[:cmeul_id])
    @course_step_log.quiz_attempts.create(user_id: current_user.try(:id), quiz_question_id: params[:question_id], quiz_answer_id: params[:answer_id], answer_array: params[:answer_array])
  end

  def update_practice_question_data
    @course_step_log = CourseStepLog.find(params[:cmeul_id])
    @course_step_log.quiz_attempts.create(user_id: current_user.try(:id), quiz_question_id: params[:question_id], quiz_answer_id: params[:answer_id], answer_array: params[:answer_array])

    respond_to do |format|
      format.json do
        if video_cme_user_log.update(update_params)
          render json: {}, status: :ok
        else
          render json: { video_log_id: video_cme_user_log.errors.messages }, status: :error
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Invalid course_step_log_id' }, status: :ok
  end

  def search
    @level   = Level.find(params[:level_id])
    @courses = @level.courses
    @courses = @courses.where(key_area_id: params[:key_area_id]) if params[:key_area_id].present?
    @courses = @courses.where(api_unit_label: params[:units])    if params[:units].present?
    @courses = @courses.where(hour_label: params[:hours])        if params[:hours].present?

    # binding.pry
    # binding.pry
    respond_to do |format|
      format.js
    end
  end

  private

  def allowed_params
    params.require(:course_step_log).permit(
      :preview_mode,
      :course_id,
      :course_lesson_log_id,
      :course_log_id,
      :course_section_id,
      :course_section_log_id,
      :course_lesson_id,
      :course_step_id,
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
    params.require(:course_step_log).permit(
      constructed_response_attempt_attributes: [
        :id,
        :constructed_response_id,
        :scenario_id,
        :course_step_id,
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
    @course_step_log = CourseStepLog.create(
      session_guid: current_session_guid,
      course_step_id: @course_step.id,
      course_lesson_id: @course_step.course_lesson_id,
      course_section_id: @course_step.course_lesson.course_section_id,
      course_id: @course_step.course_lesson.course_id,
      course_log_id: @course_log.try(:id),
      course_section_log_id: @course_section_log.try(:id),
      course_lesson_log_id: @course_lesson_log.try(:id),
      quiz_result: 'started',
      is_quiz: true,
      is_video: false,
      user_id: current_user.try(:id)
    )

    @mathjax_required    = true
    @strategy            = @course_step.course_quiz.question_selection_strategy
    @number_of_questions = @course_step.course_quiz.number_of_questions
    @quiz_questions      =
      if @strategy == 'random'
        @course_step.course_quiz.quiz_questions.all_in_order.includes(:quiz_contents).shuffle.take(@number_of_questions)
      else
        @course_step.course_quiz.quiz_questions.all_in_order.includes(:quiz_contents).take(@number_of_questions)
      end

    previous_scores = @course_step_log.course_lesson_log&.course_step_logs&.for_user(current_user.id)&.for_course_step(@course_step.id)&.all_completed&.map(&:quiz_score_actual)
    @previous_best_score = previous_scores.any? ? previous_scores.max.to_s + '%' : nil
    previous_passes = @course_step_log.course_lesson_log&.course_step_logs&.for_user(current_user.id)&.for_course_step(@course_step.id)&.all_completed&.map(&:quiz_result)
    @previously_passed = previous_passes.include?('passed').to_s
  end

  def set_up_notes
    @course_step_log = CourseStepLog.create(
      session_guid: current_session_guid,
      course_step_id: @course_step.id,
      course_lesson_id: @course_step.course_lesson_id,
      course_section_id: @course_step.course_lesson.course_section_id,
      course_id: @course_step.course_lesson.course_id,
      course_log_id: @course_log.try(:id),
      course_section_log_id: @course_section_log.try(:id),
      course_lesson_log_id: @course_lesson_log.try(:id),
      is_quiz: false,
      is_video: false,
      is_note: true,
      user_id: current_user.try(:id)
    )
  end

  def set_up_practice_question
    course_step_logs_practice_question

    @course_step_log.update(session_guid: current_session_guid)
    @course_step_log.build_practice_question_answers
    @course_step_logs = @course_step_logs.map { |l| { id: l.id, created: timer_datetime(l.created_at) } }
    @course_step_logs.delete({ id: @course_step_log.id, created: timer_datetime(@course_step_log.created_at) })
    @course_step_logs << ({ id: @course_step_log.id, created: 'Current attempt' })
  end

  def course_step_logs_practice_question
    course_step_log_params = { course_step_id: @course_step.id,
                               course_lesson_id: @course_step.course_lesson_id,
                               course_section_id: @course_step.course_lesson.course_section_id,
                               course_id: @course_step.course_lesson.course_id,
                               course_log_id: @course_log.try(:id),
                               course_section_log_id: @course_section_log.try(:id),
                               course_lesson_log_id: @course_lesson_log.try(:id),
                               is_practice_question: true,
                               user_id: current_user.try(:id) }

    @course_step_logs = CourseStepLog.where(course_step_log_params)
    @course_step_log =
      if @course_step_logs.present?
        @course_step_logs.last
      else
        CourseStepLog.find_or_create_by(course_step_log_params)
      end

    return if @course_step_log.element_completed == false

    @course_step_log = @course_step_log.dup
    @course_step_log.element_completed = false
  end

  def set_up_constructed_response_start_screen
    # Order by most recently updated_at
    @course_step_logs = @course_log.course_step_logs.for_course_step(@course_step.id).reverse[0...8] if @course_log
  end

  def set_up_new_constructed_response
    @mathjax_required = true
    @time_allowed = @course_step.constructed_response.time_allowed
    @constructed_response = @course_step.constructed_response
    @all_questions = @constructed_response.scenario.scenario_questions.all_in_order
    @all_question_ids = @constructed_response.scenario.scenario_questions.all_in_order.map(&:id)
    @course_log = current_user.course_logs.for_course(@course.id).last if current_user.course_logs.any?
    @course_section_log = @course_log.course_section_logs.where(course_section_id: @course_section.id).last if @course_log
    @course_lesson_log = @course_section_log.course_lesson_logs.where(course_lesson_id: @course_lesson.id).last if @course_section_log

    # Creates CONSTRUCTED_RESPONSE log when page renders
    @course_step_log = CourseStepLog.create!(
      preview_mode: @preview_mode,
      session_guid: current_session_guid,
      course_lesson_id: @course_step.course_lesson_id,
      course_section_id: @course_step.course_lesson.course_section_id,
      course_id: @course_step.course_lesson.course_section.course_id,
      course_log_id: @preview_mode ? nil : @course_log.try(:id),
      course_section_log_id: @preview_mode ? nil : @course_section_log.try(:id),
      course_lesson_log_id: @preview_mode ? nil : @course_lesson_log.try(:id),
      course_step_id: @course_step.id,
      time_taken_in_seconds: @course_step.estimated_time_in_seconds,
      is_quiz: false,
      is_video: false,
      is_constructed_response: true,
      user_id: current_user.id
    )
    @constructed_response_attempt = ConstructedResponseAttempt.create!(
      constructed_response_id: @constructed_response.id,
      scenario_id: @constructed_response.scenario.id,
      course_step_id: @constructed_response.course_step_id,
      course_step_log_id: @course_step_log.id,
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
    @constructed_response = @course_step.constructed_response
    @time_allowed = @constructed_response.time_allowed
    @all_question_ids = @constructed_response.scenario.scenario_questions.all_in_order.map(&:id)

    @course_log = current_user.course_logs.for_course(@course.id).last if current_user.course_logs.any?
    @course_section_log = @course_log.course_section_logs.where(course_section_id: @course_section.id).last if @course_log
    @course_lesson_log = @course_section_log.course_lesson_logs.where(course_lesson_id: @course_lesson.id).last if @course_section_log

    @course_step_log = CourseStepLog.find(params[:course_step_log_id])
    @constructed_response_attempt = @course_step_log.constructed_response_attempt

    @all_scenario_question_attempt = @constructed_response_attempt.scenario_question_attempts.all_in_order
    @all_scenario_question_attempt_ids = @constructed_response_attempt.scenario_question_attempts.all_in_order.map(&:id)
  end

  def set_up_course_step_log
    @course_step_log.calculate_score
    @course_step_log.update(allowed_params)
    @course_step_log.session_guid = current_session_guid

    @course_step           = @course_step_log.course_step
    @course_log            = @course_step_log.course_log
    @course_lesson         = @course_step_log.course_lesson
    @course                = @course_lesson.course
    @group                 = @course.group
    @valid_subscription    = current_user.active_subscriptions_for_exam_body(@group.exam_body_id).
                               all_valid.first
    @course_step_log.course_id = @course.id
    @results = true
  end

  protected

  def check_permission
    @course = Course.find_by(name_url: params[:course_name_url])
    @group = @course.group
    @course_section = @course.course_sections.all_active.find_by(name_url: params[:course_section_name_url]) if @course
    @course_lesson = @course_section.course_lessons.all_active.find_by(name_url: params[:course_lesson_name_url]) if @course_section
    @course_step = @course_lesson.course_steps.all_active.find_by(name_url: params[:course_step_name_url]) if @course_lesson
    @course_log = current_user.course_logs.for_course(@course.id).all_in_order.last
    @valid_subscription = current_user.active_subscriptions_for_exam_body(@group.exam_body_id).all_valid.first
    permission = @course_step&.available_to_user(current_user, @valid_subscription, @course_log)

    return if @course_step && permission && permission[:view]

    if permission && permission[:reason]
      redirect_to library_course_url(@group.name_url, @course.name_url, anchor: permission[:reason])
    else
      flash[:warning] = 'Sorry, you are not permitted to access that content.'
      redirect_to library_special_link(@course)
    end
  rescue NoMethodError => _e
    flash[:warning] = 'Sorry, that content doesn\'t exist or was inactivated.'
    redirect_to library_special_link(@course)
  end
end
