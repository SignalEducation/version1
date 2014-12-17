class CoursesController < ApplicationController

  def show
    @exam_section = @exam_level = @qualification = @institution = @subject_area = nil
    @course_module_element = CourseModuleElement.where(name_url: params[:course_module_element_name_url]).first
    unless @course_module_element
      @course_module = CourseModule.where(name_url: params[:course_module_name_url]).first
      unless @course_module
        @exam_section = params[:exam_section_name_url] == 'all' ?
              nil :
              @exam_section = ExamSection.where(name_url: params[:exam_section_name_url]).first
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
      end
      redirect_to library_special_link(@exam_section || @exam_level || @qualification || @institution || @subject_area || nil)
    end
  end

  def create # course_module_element_user_log and children
    @course_module_element_user_log = CourseModuleElementUserLog.new(allowed_params)
    if @course_module_element_user_log.save

    end
    if params[:demo_mode] == 'yes'
      redirect_to course_module_element_path(@course_module_element_user_log.course_module_element)
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
end
