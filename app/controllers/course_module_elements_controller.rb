# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  duration                  :float            default(0.0)
#

class CourseModuleElementsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin content_manager))
  end
  before_action :get_variables

  def show
    @course_module_element = CourseModuleElement.find(params[:id])
    if @course_module_element.is_quiz
      @course_module_element_user_log = CourseModuleElementUserLog.new(
              course_module_id: @course_module_element.course_module_id,
              course_module_element_id: @course_module_element.id,
              user_id: current_user.try(:id),
              session_guid: current_session_guid
      )
      @number_of_questions = @course_module_element.course_module_element_quiz.number_of_questions
      @number_of_questions.times do
        @course_module_element_user_log.quiz_attempts.build(user_id: current_user.try(:id))
      end
      all_questions = @course_module_element.course_module_element_quiz.quiz_questions
      all_easy_ids = all_questions.all_easy.map(&:id)
      all_medium_ids = all_questions.all_medium.map(&:id)
      all_difficult_ids = all_questions.all_difficult.map(&:id)
      @easy_ids = all_easy_ids.sample(@number_of_questions)
      @medium_ids = all_medium_ids.sample(@number_of_questions)
      @difficult_ids = all_difficult_ids.sample(@number_of_questions)
      @all_ids = @easy_ids + @medium_ids + @difficult_ids
      @quiz_questions = QuizQuestion.find(@easy_ids + @medium_ids + @difficult_ids)
      @strategy = @course_module_element.course_module_element_quiz.question_selection_strategy
      @first_attempt = @course_module_element_user_log.recent_attempts.count == 0
    end
    @demo_mode = true
  end

  def new
    @course_module_element = CourseModuleElement.new(
        sorting_order: (CourseModuleElement.all.maximum(:sorting_order).to_i + 1),
        course_module_id: params[:cm_id].to_i, active: false)
    @course_module_element.active = true
    cm = CourseModule.find params[:cm_id].to_i
    @course_modules = cm.parent.active_children
    if params[:type] == 'video'

      @course_module_element.build_course_module_element_video
      @course_module_element.is_video = true
      @course_module_element.course_module_element_resources.build
      @course_module_element.build_video_resource

      if params[:video_uri]
        @video_guid = params[:video_uri].split("/").last.to_s
      else
        @ticket = build_vimeo_ticket(new_course_module_element_url(type: 'video', cm_id: cm_id))
        @ticket_url = @ticket.upload_link_secure
      end

    elsif params[:type] == 'quiz'
      spawn_quiz_children
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
        if !@course_module_element.video_resource
          @course_module_element.build_video_resource
        end
        if params[:video_uri]
          @video_guid = params[:video_uri].split("/").last.to_s
        else
          @ticket = build_vimeo_ticket(edit_course_module_element_url(type: 'video', cm_id: cm.id, course_module_element_id: @course_module_element.id))
          @ticket_url = @ticket.upload_link_secure
        end
      end
      @course_modules = cm.parent.active_children
      set_related_cmes
    else
      redirect_to subject_course_url(@course_module_element.parent.parent)
    end
  end

  def create
    if params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
      params[:course_module_element][:course_module_element_quiz_attributes].delete(:quiz_questions_attributes)
    end
    @course_module_element = CourseModuleElement.new(allowed_params)
    set_related_cmes
    @course_modules = @course_module_element.try(:course_module).try(:parent).try(:active_children)

    verify_upload(@course_module_element.course_module_element_video.vimeo_guid, @course_module_element.name)

    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.create.flash.success')
      if params[:commit] == I18n.t('views.course_module_elements.form.save_and_add_another')
        redirect_to edit_course_module_element_url(@course_module_element.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
        redirect_to new_quiz_question_url(cme_quiz_id: @course_module_element.course_module_element_quiz.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.preview_button')
        redirect_to @course_module_element.course_module_element_quiz.quiz_questions.last
      else
        redirect_to course_module_special_link(@course_module_element.course_module)
      end
    else
      if params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
        spawn_quiz_children
      end
      if params[:commit] == t('views.general.save') && @course_module_element.is_video && @course_module_element.course_module_element_resources.empty?
        @course_module_element.course_module_element_resources.build
      end
      render action: :new
    end
  end

  def update
    old_cm = @course_module_element.parent
    set_related_cmes
    Rails.logger.debug "STARTING...."
    @course_module_element.assign_attributes(allowed_params)
    Rails.logger.debug "CONTINUING..."
    @course_module_element.valid?
    Rails.logger.debug "DEBUG: course_module_elements_controller#update about to save. Errors:#{@course_module_element.errors.inspect}."
    cm = @course_module_element.parent
    @course_modules = cm.parent.active_children

    verify_upload(@course_module_element.course_module_element_video.vimeo_guid, @course_module_element.name)
    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.update.flash.success')
      if params[:commit] == I18n.t('views.course_module_elements.form.save_and_add_another')
        redirect_to edit_course_module_element_url(@course_module_element.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.preview_button')
        redirect_to @course_module_element.course_module_element_quiz.quiz_questions.last
      else
        redirect_to course_module_special_link(@course_module_element.course_module)
      end
      if old_cm.id != cm.id
        old_cm.save!
      end
    else
      Rails.logger.debug "DEBUG: course_module_elements_controller#update failed. Errors:#{@course_module_element.errors.inspect}."
      render action: :edit
    end
  end

  def quiz_questions_order
    @quiz_questions = @course_module_element.course_module_element_quiz.quiz_questions
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      CourseModuleElement.find(the_id.to_i).update_columns(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @course_module_element.destroy
      flash[:success] = I18n.t('controllers.course_module_elements.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.course_module_elements.destroy.flash.error')
    end
    redirect_to course_module_special_link(@course_module_element.course_module)
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @course_module_element = CourseModuleElement.where(id: params[:id]).first
    end
    @tutors = User.all_tutors.all_in_order
    @letters = ('A'..'Z').to_a
    @mathjax_required = true
  end


  def build_vimeo_ticket(url)
    require 'net/http'
    require 'net/http/post/multipart'
    http = Net::HTTP.new('api.vimeo.com', 443)
    http.use_ssl = true

    http.start do |session|
      request = Net::HTTP::Post.new('/me/videos')
      request['authorization'] = 'Bearer a3b067f4c5605adb58d0fc1f599d76a6'
      request.form_data = {'redirect_url' => url}
      response = session.request(request)
      ticket = OpenStruct.new(JSON.parse(response.body))
      return ticket
    end

  end


  def verify_upload(video_uri, cme_name)
    require 'net/http'
    require 'net/http/post/multipart'
    http = Net::HTTP.new('api.vimeo.com', 443)
    http.use_ssl = true

    http.start do |session|
      request = Net::HTTP::Patch.new("/videos/#{video_uri}")
      request['authorization'] = 'Bearer a3b067f4c5605adb58d0fc1f599d76a6'
      request.form_data = {'name' => cme_name}
      response = session.request(request)
      if response.code == 308
        range = response.range
      end
      binding.pry
    end
  end


  def set_related_cmes
    if @course_module_element && @course_module_element.course_module
      @related_cmes = @course_module_element.course_module.course_module_elements.all_videos
    else
      @related_cmes = CourseModuleElement.none
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
        :related_quiz_id,
        :related_video_id,
        :is_video,
        :is_quiz,
        :seo_description,
        :seo_no_index,
        :number_of_questions,
        course_module_element_video_attributes: [
            :course_module_element_id,
            :id,
            :difficulty_level,
            :duration,
            :transcript,
            :thumbnail,
            :vimeo_guid,
            :vimeo_upload_ticket_id,
            :video_id],
        course_module_element_quiz_attributes: [
            :id,
            :course_module_element_id,
            :number_of_questions,
            :question_selection_strategy,
            :is_final_quiz,
            quiz_questions_attributes: [
                :id,
                :course_module_element_quiz_id,
                :difficulty_level,
                :hints,
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
                    :content_type,
                    :sorting_order
                ],
                quiz_answers_attributes: [
                    :id,
                    :quiz_question_id,
                    :degree_of_wrongness,
                    :wrong_answer_explanation_text,
                    :wrong_answer_video_id,
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
                        :content_type,
                        :sorting_order]
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
                    :content_type,
                    :sorting_order]
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
        video_resource_attributes:  [
            :id,
            :course_module_element_id,
            :question,
            :answer,
            :notes,
            :transcript,
        ]
    )
  end

  def spawn_quiz_children
    @course_module_element.is_quiz = true
    @course_module_element.build_course_module_element_quiz
    @course_module_element.course_module_element_quiz.add_an_empty_question
    @course_module_element.course_module_element_quiz.quiz_questions.last.course_module_element_quiz_id = @course_module_element.course_module_element_quiz.id
  end

end
