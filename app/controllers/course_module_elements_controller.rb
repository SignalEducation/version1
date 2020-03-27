# frozen_string_literal: true

class CourseModuleElementsController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[content_management_access]) }
  before_action :management_layout
  before_action :get_variables, except: :clone

  def show
    # Previewing a Quiz as Content Manager or Admin
    @course_module_element = CourseModuleElement.find(params[:id])
    if @course_module_element.is_quiz
      @module_log = ModuleLog.new(
              course_module_id: @course_module_element.course_module_id,
              course_module_element_id: @course_module_element.id,
              user_id: current_user.try(:id),
              session_guid: current_session_guid
      )
      @number_of_questions = @course_module_element.course_module_element_quiz.number_of_questions
      @number_of_questions.times do
        @module_log.quiz_attempts.build(user_id: current_user.try(:id))
      end
      all_ids_random = @course_module_element.course_module_element_quiz.all_ids_random
      all_ids_ordered = @course_module_element.course_module_element_quiz.all_ids_ordered
      @strategy = @course_module_element.course_module_element_quiz.question_selection_strategy

      if @strategy == 'random'
        @all_ids = all_ids_random.sample(@number_of_questions)
        @quiz_questions = QuizQuestion.includes(:quiz_contents).find(@all_ids)
      else
        @all_ids = all_ids_ordered[0..@number_of_questions]
        @quiz_questions = QuizQuestion.includes(:quiz_contents).find(@all_ids)
      end
    end

    @demo_mode = true
  end

  def new
    cm = CourseModule.find params[:cm_id].to_i
    @lessons = cm.parent.children
    @related_cmes = cm.course_module_elements.all_active
    @course_module_element = CourseModuleElement.new(
        sorting_order: (CourseModuleElement.all.maximum(:sorting_order).to_i + 1),
        course_module_id: cm.id, active: true)

    if params[:type] == 'video'

      @course_module_element.is_video = true
      @course_module_element.build_course_module_element_video
      @course_module_element.build_video_resource
      @course_module_element.course_module_element_resources.build

    elsif params[:type] == 'quiz'
      spawn_quiz_children
    elsif params[:type] == 'constructed_response'
      spawn_constructed_response_children
    end
    set_related_cmes
  end

  def edit
    if @course_module_element
      cm = @course_module_element.parent
      if @course_module_element.is_quiz
        @course_module_element.course_module_element_quiz.add_an_empty_question
      elsif @course_module_element.is_video
        @course_module_element.course_module_element_resources.build
        unless @course_module_element.video_resource
          @course_module_element.build_video_resource
        end
      elsif @course_module_element.is_constructed_response
        @course_module_element.constructed_response.scenario.add_an_empty_scenario_question
      end
      @lessons = cm.parent.active_children
      set_related_cmes
    else
      redirect_to course_url(@course_module_element.parent.parent)
    end
  end

  def create
    if params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
      params[:course_module_element][:course_module_element_quiz_attributes].delete(:quiz_questions_attributes)
    end
    @course_module_element = CourseModuleElement.new(allowed_params)
    set_related_cmes
    @lessons = @course_module_element.try(:course_module).try(:parent).try(:active_children)

    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.create.flash.success')
      if params[:commit] == I18n.t('views.course_module_elements.form.save_and_add_another')
        redirect_to edit_course_module_element_url(@course_module_element.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
        redirect_to new_quiz_question_url(cme_quiz_id: @course_module_element.course_module_element_quiz.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.preview_button')
        redirect_to @course_module_element.course_module_element_quiz.quiz_questions.last
      else
        redirect_to show_course_module_url(@course_module_element.course_module.course_id, @course_module_element.course_module.course_section.id, @course_module_element.course_module.id)
      end
    else
      if params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
        spawn_quiz_children
      end
      render action: :new
    end
  end

  def update
    old_cm = @course_module_element.parent
    set_related_cmes
    @course_module_element.assign_attributes(allowed_params)
    cm = @course_module_element.parent
    @lessons = cm.parent.active_children

    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.update.flash.success')
      if params[:commit] == I18n.t('views.course_module_elements.form.save_and_add_another')
        redirect_to edit_course_module_element_url(@course_module_element.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.preview_button')
        redirect_to @course_module_element.course_module_element_quiz.quiz_questions.last
      else
        redirect_to course_module_special_link(@course_module_element.course_module)
      end

      old_cm.update_video_and_quiz_counts unless old_cm.id == cm.id
    else
      Rails.logger.debug "DEBUG: course_module_elements_controller#update failed. Errors:#{@course_module_element.errors.inspect}."
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseModuleElement.find(the_id.to_i).update_columns(sorting_order: (counter + 1))
    end
    render json: {}, status: :ok
  end

  def destroy
    if @course_module_element.destroy
      flash[:success] = I18n.t('controllers.course_module_elements.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_module_elements.destroy.flash.error')
    end
    redirect_to course_module_special_link(@course_module_element.course_module)
  end

  # Reordering of Questions if CMEQ selection_strategy is not random #
  def quiz_questions_order
    @quiz_questions = @course_module_element.course_module_element_quiz.quiz_questions
  end

  def clone
    cme = CourseModuleElement.find(params[:course_module_element_id])

    case cme.type_name
    when 'Constructed Response'
      cme.constructed_response.duplicate
      flash[:success] = 'Constructed Response successfully duplicaded'
    when 'Quiz'
      cme.course_module_element_quiz.duplicate
      flash[:success] = 'Quiz successfully duplicaded'
    when 'Video'
      cme.course_module_element_video.duplicate
      flash[:success] = 'Video successfully duplicaded'
    else
      flash[:error] = 'Course Element was not successfully duplicaded'
    end

    redirect_to show_course_module_path(cme.course_module.course_id,
                                        cme.course_module.course_section.id, cme.course_module.id)
  end

  protected

  def get_variables
    @course_module_element = CourseModuleElement.where(id: params[:id]).first if params[:id].to_i > 0
    @tutors = User.all_tutors.all_in_order
    @letters = ('A'..'Z').to_a
    @mathjax_required = true
  end

  def spawn_quiz_children
    @course_module_element.is_quiz = true
    @course_module_element.build_course_module_element_quiz
    @course_module_element.course_module_element_quiz.add_an_empty_question
    @course_module_element.course_module_element_quiz.quiz_questions.last.course_module_element_quiz_id = @course_module_element.course_module_element_quiz.id
  end

  def spawn_constructed_response_children
    @course_module_element.is_constructed_response = true
    @course_module_element.build_constructed_response
    @course_module_element.constructed_response.add_an_empty_scenario
  end

  def set_related_cmes
    @related_cmes =
      if @course_module_element&.course_module
        @course_module_element.course_module.course_module_elements.all_in_order.where.not(id: @course_module_element.id)
      else
        CourseModuleElement.none
      end
  end

  def allowed_params
    params.require(:course_module_element).permit(
      :name,
      :name_url,
      :description,
      :estimated_time_in_seconds,
      :course_module_id,
      :sorting_order,
      :active,
      :is_video,
      :is_quiz,
      :is_constructed_response,
      :seo_description,
      :seo_no_index,
      :number_of_questions,
      :temporary_label,
      :available_on_trial,
      :related_course_module_element_id,
      course_module_element_video_attributes: [
        :course_module_element_id,
        :id,
        :duration,
        :vimeo_guid,
        :dacast_id,
        :video_id
      ],
      course_module_element_quiz_attributes: [
        :id,
        :course_module_element_id,
        :number_of_questions,
        :question_selection_strategy,
        quiz_questions_attributes: [
          :id,
          :course_module_element_quiz_id,
          :difficulty_level,
          :custom_styles,
          quiz_solutions_attributes: [
            :id,
            :quiz_question_id,
            :quiz_answer_id,
            :quiz_solution_id,
            :text_content,
            :image,
            :image_file_name,
            :image_content_type,
            :image_file_size,
            :image_updated_at,
            :sorting_order
          ],
          quiz_answers_attributes: [
            :id,
            :quiz_question_id,
            :degree_of_wrongness,
            :_destroy,
            quiz_contents_attributes: [
              :id,
              :quiz_question_id,
              :quiz_answer_id,
              :text_content,
              :image,
              :image_file_name,
              :image_content_type,
              :image_file_size,
              :image_updated_at,
              :sorting_order
            ]
          ],
          quiz_contents_attributes: [
            :id,
            :quiz_question_id,
            :quiz_answer_id,
            :text_content,
            :image,
            :image_file_name,
            :image_content_type,
            :image_file_size,
            :image_updated_at,
            :sorting_order
          ]
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
        :upload_updated_at,
        :_destroy
      ],
      video_resource_attributes: [
        :id,
        :course_module_element_id,
        :question,
        :answer,
        :notes,
        :transcript
      ],
      constructed_response_attributes: [
        :id,
        :course_module_element_id,
        scenario_attributes: [
          :id,
          :constructed_response_id,
          :sorting_order,
          :text_content,
          scenario_questions_attributes: [
            :id,
            :_destroy,
            :scenario_id,
            :sorting_order,
            :text_content,
            scenario_answer_templates_attributes: [
              :id,
              :_destroy,
              :scenario_question_id,
              :sorting_order,
              :editor_type,
              :text_editor_content,
              :spreadsheet_editor_content
            ]
          ]
        ]
      ]
    )
  end
end
