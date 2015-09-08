class LibraryController < ApplicationController

  def index
    if current_user && current_user.corporate_student?
      @exam_levels = ExamLevel.all_active.all_live.all_in_order.where(enable_exam_sections: false )
      @exam_sections = ExamSection.all_active.all_live.all_in_order
      @exam_levels = @exam_levels.where('id not in (?)', current_user.restricted_exam_level_ids) unless current_user.restricted_exam_level_ids.empty?
      @exam_sections = @exam_sections.where('id not in (?)', current_user.restricted_exam_section_ids) unless current_user.restricted_exam_section_ids.empty?
    else
      @exam_levels = ExamLevel.all_active.all_in_order.where(enable_exam_sections: false )
      @exam_sections = ExamSection.all_active.all_in_order
    end
    @levels = @exam_levels.search(params[:search])
    @sections = @exam_sections.search(params[:search])
    @courses = @levels + @sections
    @student_exam_tracks = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).order(updated_at: :desc)
    @incomplete_student_exam_tracks = @student_exam_tracks.where('percentage_complete <= ?', 100)
  end

  def show
    @exam_level = ExamLevel.where(name_url: params[:exam_level_name_url].to_s).first
    @exam_section = ExamSection.where(name_url: params[:exam_section_name_url].to_s).first
    users_sets = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_in_order
    if @exam_section.nil?
      @course = @exam_level
      user_course_sets = users_sets.where(exam_level_id: @exam_level.try(:id))
    else
      @course = @exam_section
      user_course_sets = users_sets.where(exam_section_id: @exam_section.try(:id))
    end
    latest_set = user_course_sets.first
    latest_element_id = latest_set.try(:latest_course_module_element_id)
    @next_element = CourseModuleElement.where(id: latest_element_id).first.try(:next_element)

    if @course.try(:live)
      render 'live_course'
    elsif @course.try(:live) == false
      render 'preview_course'
    else
      redirect_to library_url
    end
    seo_title_maker(@course.try(:name), @course.try(:seo_description), @course.try(:seo_no_index))
  end

  def subscribe
    email = params[:email][:address]
    list_id = params[:list_id]
    if !email.blank?
      begin
        @mc.lists.subscribe(list_id, {'email' => email})
        respond_to do |format|
          format.json{render json: {message: "Success! Check your email to confirm your subscription."}}
        end
      rescue Mailchimp::ListAlreadySubscribedError
        respond_to do |format|
          format.json{render json: {message: "#{email} is already subscribed to the list"}}
        end
      rescue Mailchimp::ListDoesNotExistError
        respond_to do |format|
          format.json{render json: {message: "The list could not be found."}}
        end
      rescue Mailchimp::Error => ex
        if ex.message
          respond_to do |format|
            format.json{render json: {message: "There is an error. Please enter valid email id."}}
          end
        else
          respond_to do |format|
            format.json{render json: {message: "An unknown error occurred."}}
          end
        end
      end
    else
      respond_to do |format|
        format.json{render json: {message: "Email Address Cannot be blank. Please enter valid email id."}}
      end
    end
  end

end
