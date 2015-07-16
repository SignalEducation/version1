class LibraryController < ApplicationController

  def index
    @exam_levels = ExamLevel.all_active.all_in_order.where(enable_exam_sections: false )
    @exam_sections = ExamSection.all_active.all_in_order
    @levels = @exam_levels.search(params[:search])
    @sections = @exam_sections.search(params[:search])
    @courses = @levels + @sections
  end

  def show
    @exam_level = ExamLevel.where(name_url: params[:exam_level_name_url].to_s).first
    @exam_section = ExamSection.where(name_url: params[:exam_section_name_url].to_s).first
    if @exam_section.nil?
      @course = @exam_level
    else
      @course = @exam_section
    end
    if @course.live
       render 'live_course'
    else
      render 'preview_course'
    end

  end

  def subscribe
    email = params[:email][:address]
    list_id = params[:list_id]

    if !email.blank?

      begin

        @mc.lists.subscribe(list_id, {'email' => email})

        respond_to do |format|
          format.json{render :json => {:message => "Success! Check your email to confirm your subscription."}}
        end

      rescue Mailchimp::ListAlreadySubscribedError

        respond_to do |format|
          format.json{render :json => {:message => "#{email} is already subscribed to the list"}}
        end

      rescue Mailchimp::ListDoesNotExistError

        respond_to do |format|
          format.json{render :json => {:message => "The list could not be found."}}
        end

      rescue Mailchimp::Error => ex

        if ex.message

          respond_to do |format|
            format.json{render :json => {:message => "There is an error. Please enter valid email id."}}
          end

        else

          respond_to do |format|
            format.json{render :json => {:message => "An unknown error occurred."}}
          end
        end

      end

    else

      respond_to do |format|
        format.json{render :json => {:message => "Email Address Cannot be blank. Please enter valid email id."}}
      end

    end
  end

  def old_show

    @subject_areas = SubjectArea.all_active.all_in_order
    @subject_area = @institution = @qualification = @exam_level = @exam_section = nil
    @subject_area = @subject_areas.where(name_url: params[:subject_area_name_url].to_s).first || @subject_areas.first
    if @subject_area
      @institution = @subject_area.institutions.where(name_url: params[:institution_name_url]).first
      if @institution
        @qualification = @institution.qualifications.where(name_url: params[:qualification_name_url]).first
        if @qualification
          @exam_level = @qualification.exam_levels.where(name_url: params[:exam_level_name_url]).first
          if @exam_level && params[:exam_section_name_url] && params[:exam_section_name_url] != 'all'
            @exam_section = @exam_level.exam_sections.where(name_url: params[:exam_section_name_url]).first
          end
        end
      end
    end
    @hierarchy_item = @exam_section || @exam_level || @qualification || @institution || @subject_area

    # SEO Titles
    if @hierarchy_item == @exam_section
      seo_title_maker("#{@institution.short_name} - #{@exam_level.name} - #{@exam_section.name}", @hierarchy_item.seo_description, @hierarchy_item.seo_no_index)
    elsif @hierarchy_item == @exam_level
      seo_title_maker("#{@institution.short_name} - #{@exam_level.name}", @hierarchy_item.seo_description, @hierarchy_item.seo_no_index)
    elsif @hierarchy_item == @qualification
      seo_title_maker("#{@institution.short_name} - #{@qualification.name}", @hierarchy_item.seo_description, @hierarchy_item.seo_no_index)
    elsif @hierarchy_item == @institution
      seo_title_maker(@institution.short_name, @hierarchy_item.seo_description, @hierarchy_item.seo_no_index)
    elsif @hierarchy_item == @subject_area
      seo_title_maker('Library', @hierarchy_item.seo_description, @hierarchy_item.seo_no_index)
    end

    @student_exam_tracks = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).order(updated_at: :desc)
    @incomplete_student_exam_tracks = @student_exam_tracks.where('percentage_complete <= ?', 100)

    unless current_user
      set_the_sign_up_redirect(@hierarchy_item)
    end
  end

  protected

  def set_the_sign_up_redirect(hierarchy_thing)
    reset_post_sign_up_redirect_path(library_special_link(hierarchy_thing.try(:exam_level) || hierarchy_thing))
  end
end
