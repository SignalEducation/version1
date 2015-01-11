class CoursesController < ApplicationController

  def show
    @mathjax_required = true
    @exam_section = @exam_level = @qualification = @institution = @subject_area = @course_module_jumbo_quiz = nil
    @course_module = CourseModule.where(name_url: params[:course_module_name_url]).first
    @course_module_element = CourseModuleElement.where(name_url: params[:course_module_element_name_url]).first
    @course_module_jumbo_quiz = @course_module.course_module_jumbo_quiz if @course_module.course_module_jumbo_quiz.try(:name_url) == params[:course_module_element_name_url]
    @course_module_element ||= @course_module.course_module_elements.all_in_order.first unless @course_module_jumbo_quiz
    if @course_module_element.nil? && @course_module.nil?
      # The URL is out of date or wrong.
      @exam_section = params[:exam_section_name_url] == 'all' ?
            nil :
            ExamSection.where(name_url: params[:exam_section_name_url]).first
      unless @exam_section
        @exam_level = ExamLevel.where(name_url: params[:exam_level_name_url]).first
        unless @exam_level
          @qualification = Qualification.where(name_url: params[:qualification_name_url]).first
          unless @qualification
            @institution = Institution.where(name_url: params[:institution_name_url]).first
            unless @institution
              @subject_area = SubjectArea.where(name_url: params[:subject_area_name_url]).first
            end
          end
        end
      end
      flash[:warning] = t('controllers.courses.show.warning')
      redirect_to library_special_link(@exam_section || @exam_level || @qualification || @institution || @subject_area || nil)
    else
      # The URL worked out Okay
      @exam_section = @course_module.exam_section
      @exam_level = @course_module.exam_level
      @qualification = @exam_level.qualification
      @institution = @qualification.institution
      @subject_area = @institution.subject_area
      if @course_module_element.try(:is_quiz)
        @course_module_element_user_log = CourseModuleElementUserLog.new(
              course_module_id: @course_module_element.course_module_id,
              course_module_element_id: @course_module_element.id,
              user_id: current_user.try(:id)
        )
        @course_module_element.course_module_element_quiz.number_of_questions.times do
          @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
        end
      elsif @course_module_jumbo_quiz
        @course_module_element_user_log = CourseModuleElementUserLog.new(
                course_module_id: @course_module.id,
                course_module_element_id: nil,
                course_module_jumbo_quiz_id: @course_module_jumbo_quiz.id,
                user_id: current_user.try(:id)
        )
        @course_module_jumbo_quiz.total_number_of_questions.times do
          @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
        end
      end
    end
  end

  def create # course_module_element_user_log and children
    @course_module_element_user_log = CourseModuleElementUserLog.new(allowed_params)
    if @course_module_element_user_log.save

    end
    if params[:demo_mode] == 'yes'
      redirect_to course_module_element_path(@course_module_element_user_log.course_module_element)
    else
      @course_module_element = @course_module_element_user_log.course_module_element
      @course_module = @course_module_element.course_module
      @results = 'abc'
      render :show
    end
  end

  private

  def allowed_params
    params.require(:course_module_element_user_log).permit(
            :course_module_id,
            :course_module_element_id,
            :user_id,
            #:session_guid,
            #:element_completed,
            :time_taken_in_seconds,
            #:quiz_score_actual,
            #:quiz_score_potential,
            #:is_video,
            #:is_quiz,
            #:latest_attempt,
            :corporate_customer_id,
            quiz_attempts_params: [
                    :id,
                    :user_id,
                    :quiz_question_id,
                    :quiz_answer_id
            ]
    )
  end

  def create_user_log

  end

end
