# frozen_string_literal: true

module Admin
  class CourseStepsController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :get_variables, except: :clone

    def show
      # Previewing a Quiz as Content Manager or Admin
      @course_step = CourseStep.find(params[:id])
      if @course_step.is_quiz
        @course_step_log = CourseStepLog.new(
                course_lesson_id: @course_step.course_lesson_id,
                course_step_id: @course_step.id,
                user_id: current_user.try(:id),
                session_guid: current_session_guid
        )
        @number_of_questions = @course_step.course_quiz.number_of_questions
        @number_of_questions.times do
          @course_step_log.quiz_attempts.build(user_id: current_user.try(:id))
        end
        all_ids_random = @course_step.course_quiz.all_ids_random
        all_ids_ordered = @course_step.course_quiz.all_ids_ordered
        @strategy = @course_step.course_quiz.question_selection_strategy

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
      lesson = CourseLesson.find params[:cm_id].to_i
      @course_lessons = lesson&.parent&.children
      @related_cmes = lesson.course_steps.all_active
      @course_step = CourseStep.new(sorting_order: (CourseStep.all.maximum(:sorting_order).to_i + 1),
                                    course_lesson_id: lesson.id, active: true)

      case params[:type]
      when 'video'
        @course_step.is_video = true
        @course_step.build_course_video
        @course_step.build_video_resource
      when 'quiz'
        spawn_quiz_children
      when 'note'
        @course_step.is_note = true
        @course_step.build_course_note
      when 'practice_question'
        @course_step.is_practice_question = true
        @course_step.build_course_practice_question
        @course_step.course_practice_question.questions.build
      when 'constructed_response'
        spawn_constructed_response_children
      end

      set_related_cmes
    end

    def edit
      if @course_step
        cm = @course_step.parent
        if @course_step.is_quiz
          @course_step.course_quiz.add_an_empty_question
          @quiz_questions = @course_step&.course_quiz&.quiz_questions&.sort_by { |q| q.sorting_order || 0 }
        elsif @course_step.is_practice_question
          @course_step.course_practice_question.questions.build
        elsif @course_step.is_video
          @course_step.build_video_resource unless @course_step.video_resource
        elsif @course_step.is_constructed_response
          @course_step.constructed_response.scenario.add_an_empty_scenario_question
        end
        @course_lessons = cm&.parent&.children
        set_related_cmes
      else
        redirect_to admin_course_url(@course_step.parent.parent)
      end
    end

    def create
      if params[:commit] == I18n.t('views.course_quizzes.form.advanced_setup_link')
        params[:course_step][:course_quiz_attributes].delete(:quiz_questions_attributes)
      end
      @course_step = CourseStep.new(allowed_params)
      set_related_cmes
      @course_lessons = @course_step.try(:course_lesson).try(:parent).try(:active_children)

      if @course_step.save
        flash[:success] = I18n.t('controllers.course_steps.create.flash.success')
        if params[:commit] == I18n.t('views.course_steps.form.save_and_add_another')
          redirect_to edit_admin_course_step_url(@course_step.id)
        elsif params[:commit] == I18n.t('views.course_quizzes.form.advanced_setup_link')
          redirect_to new_quiz_question_url(quiz_step_id: @course_step.course_quiz.id)
        elsif params[:commit] == I18n.t('views.course_quizzes.form.preview_button')
          redirect_to @course_step.course_quiz.quiz_questions.last
        elsif @course_step.course_lesson.free
          redirect_to admin_course_free_lesson_content_path(@course_step.course_lesson.course)
        else
          redirect_to admin_show_course_lesson_url(@course_step.course_lesson.course_id, @course_step.course_lesson.course_section.id, @course_step.course_lesson.id)
        end
      else
        if params[:commit] == I18n.t('views.course_quizzes.form.advanced_setup_link')
          spawn_quiz_children
        end
        render action: :new
      end
    end

    def update
      old_cm = @course_step.parent
      set_related_cmes
      @course_step.assign_attributes(allowed_params)
      cm = @course_step.parent
      @course_lessons = cm&.parent&.active_children

      if @course_step.save
        flash[:success] = I18n.t('controllers.course_steps.update.flash.success')
        if params[:commit] == I18n.t('views.course_steps.form.save_and_add_another')
          redirect_to edit_admin_course_step_url(@course_step.id)
        elsif params[:commit] == I18n.t('views.course_quizzes.form.preview_button')
          redirect_to @course_step.course_quiz.quiz_questions.last
        elsif @course_step.course_lesson.free
          redirect_to admin_course_free_lesson_content_path(@course_step.course_lesson.course)
        else
          redirect_to admin_show_course_lesson_url(@course_step.course_lesson.course_id, @course_step.course_lesson.course_section.id, @course_step.course_lesson.id)
        end

        old_cm.update_video_and_quiz_counts unless old_cm.id == cm.id
      else
        Rails.logger.debug "DEBUG: course_steps_controller#update failed. Errors:#{@course_step.errors.inspect}."
        render action: :edit
      end
    end

    def reorder
      array_of_ids = params[:array_of_ids]
      array_of_ids.each_with_index do |the_id, counter|
        CourseStep.find(the_id.to_i).update_columns(sorting_order: (counter + 1))
      end
      render json: {}, status: :ok
    end

    def destroy
      if @course_step.destroy
        flash[:success] = I18n.t('controllers.course_steps.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.course_steps.destroy.flash.error')
      end

      redirect_to admin_show_course_lesson_url(@course_step.course_lesson.course_id, @course_step.course_lesson.course_section.id, @course_step.course_lesson.id)
    end

    def remove_question
      if PracticeQuestion::Question.find(params[:question_id]).destroy
        flash[:success] = I18n.t('controllers.course_practice_question.questions.destroy.flash.success')
      else
        flash[:error] = I18n.t('controllers.course_practice_question.question.destroy.flash.error')
      end

      redirect_to edit_admin_course_step_url(@course_step.id)
    end

    # Reordering of Questions if CMEQ selection_strategy is not random #
    def quiz_questions_order
      @quiz_questions = @course_step.course_quiz.quiz_questions
    end

    def clone
      cme = CourseStep.find(params[:course_step_id])

      case cme.type_name
      when 'Constructed Response'
        cme.constructed_response.duplicate
        flash[:success] = 'Constructed Response successfully duplicaded'
      when 'Quiz'
        cme.course_quiz.duplicate
        flash[:success] = 'Quiz successfully duplicaded'
      when 'Notes'
        cme.course_note.duplicate
        flash[:success] = 'Video successfully duplicaded'
      when 'Video'
        cme.course_video.duplicate
        flash[:success] = 'Video successfully duplicaded'
      else
        flash[:error] = 'Course Element was not successfully duplicaded'
      end

      redirect_to admin_show_course_lesson_path(cme.course_lesson.course_id,
                                                cme.course_lesson.course_section.id,
                                                cme.course_lesson.id)
    end

    protected

    def get_variables
      @course_step = CourseStep.where(id: params[:id]).first if params[:id].to_i > 0
      @tutors = User.all_tutors.all_in_order
      @letters = ('A'..'Z').to_a
      @mathjax_required = true
    end

    def spawn_quiz_children
      @course_step.is_quiz = true
      @course_step.build_course_quiz
      @course_step.course_quiz.add_an_empty_question
      @course_step.course_quiz.quiz_questions.last.course_quiz_id = @course_step.course_quiz.id
    end

    def spawn_constructed_response_children
      @course_step.is_constructed_response = true
      @course_step.build_constructed_response
      @course_step.constructed_response.add_an_empty_scenario
    end

    def set_related_cmes
      @related_cmes =
        if @course_step&.course_lesson
          @course_step.course_lesson.course_steps.all_in_order.where.not(id: @course_step.id)
        else
          CourseStep.none
        end
    end

    def allowed_params
      params.require(:course_step).permit(
        :name,
        :name_url,
        :description,
        :estimated_time_in_seconds,
        :vid_end_seconds,
        :course_lesson_id,
        :sorting_order,
        :active,
        :is_video,
        :is_note,
        :is_quiz,
        :is_practice_question,
        :is_constructed_response,
        :seo_description,
        :seo_no_index,
        :number_of_questions,
        :temporary_label,
        :available_on_trial,
        :related_course_step_id,
        course_video_attributes: [
          :course_step_id,
          :id,
          :duration,
          :vimeo_guid,
          :dacast_id,
          :video_id
        ],
        course_practice_question_attributes: [
          :course_step_id,
          :id,
          :name,
          :content,
          :kind,
          :estimated_time,
          :document,
          questions_attributes: [
            :id,
            :kind,
            :course_practice_question_id,
            :description,
            :content,
            :solution,
            :sorting_order
          ]
        ],
        course_note_attributes: [
          :course_step_id,
          :id,
          :name,
          :upload,
          :download_available
        ],
        course_quiz_attributes: [
          :id,
          :course_step_id,
          :number_of_questions,
          :question_selection_strategy,
          quiz_questions_attributes: [
            :id,
            :course_quiz_id,
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
        course_notes_attributes: [
          :id,
          :course_step_id,
          :name,
          :download_available,
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
          :course_step_id,
          :question,
          :answer,
          :notes,
          :transcript
        ],
        constructed_response_attributes: [
          :id,
          :course_step_id,
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
end
