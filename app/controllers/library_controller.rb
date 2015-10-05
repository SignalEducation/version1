class LibraryController < ApplicationController

  def index
    if current_user && (current_user.corporate_student? || current_user.corporate_customer?)
      @subject_courses = SubjectCourse.all_active.all_live.all_in_order
      @non_restricted_courses = @subject_courses.where('id not in (?)', current_user.restricted_subject_course_ids) unless current_user.restricted_subject_course_ids.empty?
      if current_user.restricted_subject_course_ids.empty?
        @courses = @subject_courses.search(params[:search])
      else
        @courses = @non_restricted_courses.search(params[:search])
      end
    else
      @subject_courses = SubjectCourse.all_active.all_in_order.all_not_restricted
      @courses = @subject_courses.search(params[:search])
    end

    @student_exam_tracks = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).order(updated_at: :desc)
    @incomplete_student_exam_tracks = @student_exam_tracks.where('percentage_complete <= ?', 100)
  end

  def show
    @course = SubjectCourse.where(name_url: params[:subject_course_name_url].to_s).first
    @duration = @course.try(:total_video_duration) + @course.try(:estimated_time_in_seconds)
    if @course.corporate_customer_id
      if @course.restricted && (current_user.corporate_customer_id == nil || current_user.corporate_customer_id != @course.corporate_customer_id)
        redirect_to library_url
      end
    end
    users_sets = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_incomplete.all_in_order
    user_course_sets = users_sets.where(subject_course_id: @course.try(:id))
    latest_set = user_course_sets.first
    @latest_element_id = latest_set.try(:latest_course_module_element_id)
    @next_element = CourseModuleElement.where(id: @latest_element_id).first.try(:next_element)
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
