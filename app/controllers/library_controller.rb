class LibraryController < ApplicationController

  def index
    @navbar = nil
    if current_user && (current_user.corporate_student? || current_user.corporate_customer?)
      #Filter Groups for corporate students by corporate_customer_id and by restrictions.
      all_groups = Group.all_active.all_in_order
      public_groups = all_groups.for_public
      private_groups = all_groups.for_corporates
      users_private_groups = private_groups.where(corporate_customer_id: current_user.corporate_customer_id)
      non_restricted_private_groups = users_private_groups.where.not(id: current_user.restricted_group_ids)
      non_restricted_public_groups = public_groups.where.not(id: current_user.restricted_group_ids)
      @groups = (non_restricted_private_groups + non_restricted_public_groups).uniq

      grouped_courses = []
      @groups.each do |group|
        group.active_children.each do |course|
          grouped_courses << course.id
        end
      end
      ids = grouped_courses.uniq
      no_grouped_corp_courses = SubjectCourse.where.not(id: ids).for_corporates.where(corporate_customer_id: current_user.corporate_customer_id)
      no_grouped_non_corp_courses = SubjectCourse.where.not(id: ids).for_public
      @no_grouped_courses = no_grouped_corp_courses + no_grouped_non_corp_courses

    else
      @groups = Group.all_active.for_public.all_in_order
      grouped_courses = []
      @groups.each do |group|
        group.active_children.each do |course|
          grouped_courses << course.id
        end
      end
      ids = grouped_courses.uniq
      @no_grouped_courses = SubjectCourse.where.not(id: ids).for_public.all_active.all_live.all_not_restricted
    end
    seo_title_maker('Library', 'Learn anytime, anywhere from our library of business-focused courses taught by expert tutors.', nil)
  end

  def show
    @course = SubjectCourse.where(name_url: params[:subject_course_name_url].to_s).first
    if @course.nil?
      redirect_to library_url
    else
      tag_manager_data_layer(@course.try(:name))
      @duration = @course.try(:total_video_duration) + @course.try(:estimated_time_in_seconds)
      if @course.corporate_customer_id
        if current_user.nil? || (@course.restricted && (current_user.corporate_customer_id == nil || current_user.corporate_customer_id != @course.corporate_customer_id))
          redirect_to library_url
        else
          users_sets = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_incomplete.all_in_order
          user_course_sets = users_sets.where(subject_course_id: @course.try(:id))
          latest_set = user_course_sets.first
          @latest_element_id = latest_set.try(:latest_course_module_element_id)
          @next_element = CourseModuleElement.where(id: @latest_element_id).first.try(:next_element)
          if @course.try(:live)
            render 'live_course'
          elsif !@course.try(:live)
            @navbar = nil
            render 'preview_course'
          else
            redirect_to library_url
          end
          seo_title_maker(@course.try(:name), @course.try(:seo_description), @course.try(:seo_no_index))
        end
      else

        @course_modules = @course.children.all_active.all_in_order
        @tuition_course_modules = @course_modules.all_tuition
        @test_course_modules = @course_modules.all_test
        @revision_course_modules = @course_modules.all_revision

        users_sets = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_incomplete.all_in_order
        user_course_sets = users_sets.where(subject_course_id: @course.try(:id))
        latest_set = user_course_sets.first
        @latest_element_id = latest_set.try(:latest_course_module_element_id)
        @next_element = CourseModuleElement.where(id: @latest_element_id).first.try(:next_element)
        @subject_course_user_log = SubjectCourseUserLog.for_user_or_session(current_user.try(:id), current_session_guid).where(subject_course_id: @course.id).all_in_order.first
        cmeuls = CourseModuleElementUserLog.for_user_or_session(current_user, current_session_guid).where(is_question_bank: true).where(question_bank_id: @course.try(:question_bank).try(:id))
        scores = cmeuls.all.map(&:quiz_score_actual)
        pass_rate = @course.cpd_pass_rate || 65
        array = []
        scores.each { |score| score >= pass_rate ? array << true : array << false }
        array2 = array.uniq
        @question_bank_passed = array2.include? true
        @cert = SubjectCourseUserLog.for_user_or_session(current_user.try(:id), current_session_guid).where(subject_course_id: @course.id).first
        cme_ids = @course.course_module_elements.all_active.map(&:id)
        @course_resources = CourseModuleElementResource.where(course_module_element_id: cme_ids)

        if @course.try(:live)
          seo_title_maker(@course.try(:name), @course.try(:description), @course.try(:seo_no_index))
          render 'live_course'
        elsif !@course.try(:live)
          seo_title_maker(@course.try(:name), @course.try(:description), @course.try(:seo_no_index))
          @navbar = nil
          render 'preview_course'
        else
          redirect_to library_url
        end
      end
    end
  end

  def cert
    log = SubjectCourseUserLog.where(id: params[:id]).first
    certificate = CompletionCertificate.where(subject_course_user_log_id: log.id, user_id: log.user_id).first
    if certificate.nil?
      guid = SecureRandom.hex(10)
      @cert = CompletionCertificate.new(user_id: log.user_id)
      @cert.subject_course_user_log_id = log.id
      @cert.guid = guid
      if @cert.valid? && @cert.save
        respond_to do |format|
          format.html
          format.pdf do
            pdf = Certificate.new(@cert, view_context)
            send_data pdf.render, filename: "certificate_#{@cert.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf", page_layout: 'landscape', page_size: '2A0'
          end
        end
      end
    else
      @cert = certificate
      respond_to do |format|
        format.html
        format.pdf do
          pdf = Certificate.new(@cert, view_context)
          send_data pdf.render, filename: "certificate_#{@cert.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf", page_layout: 'landscape', page_size: '2A0'
        end
      end
    end
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
