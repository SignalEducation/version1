class CourseModuleElementsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'tutor', 'content_manager'])
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
    @course_module_element.tutor_id = @course_module_element.course_module.tutor_id
    if params[:type] == 'video'
      @course_module_element.build_course_module_element_video
      @course_module_element.course_module_element_resources.build
      @course_module_element.is_video = true
    elsif params[:type] == 'quiz'
      spawn_quiz_children
    elsif params[:type] == 'flash_cards'
      @course_module_element.is_cme_flash_card_pack = true
      create_empty_cme_flash_card_pack
    end
    set_related_cmes
  end

  def edit
    if @course_module_element.is_quiz
      @course_module_element.course_module_element_quiz.add_an_empty_question
    elsif @course_module_element.is_video
      @course_module_element.course_module_element_resources.build
    elsif @course_module_element.is_cme_flash_card_pack
      # edit_empty_cme_flash_card_pack
      if @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.content_type == 'Cards'
        # @flash_quiz = @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.build_flash_quiz
        # @quiz_question = @flash_quiz.quiz_questions.build
        # @quiz_question.quiz_contents.build(sorting_order: 0)


      else
        # flash_card = @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_cards.build(sorting_order: 0)
        # flash_card.quiz_contents.build(sorting_order: 0)

      end

    end
    set_related_cmes
  end

  def create
    if params[:commit] == I18n.t('views.course_module_element_quizzes.form.advanced_setup_link')
      params[:course_module_element][:course_module_element_quiz_attributes].delete(:quiz_questions_attributes)
    end
    @course_module_element = CourseModuleElement.new(allowed_params)
    set_related_cmes
    if @course_module_element.is_video
      upload_io = params[:course_module_element][:course_module_element_video_attributes][:video]
      response = post_video_to_wistia(@course_module_element.name.to_s, upload_io.path)
      wistia_data = response.body
      @course_module_element.course_module_element_video.video_id = wistia_data.split(',')[6].split(':')[1].tr("\"", "")
      @course_module_element.course_module_element_video.duration = wistia_data.split(',')[5].split(':')[1].tr("\"", "")
      thumbnail_url = wistia_data.split(',')[10].split(':{')[1].split(':')[-1].chop.prepend('https:')
      @course_module_element.course_module_element_video.thumbnail = thumbnail_url
    end
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

  def post_video_to_wistia(name, path_to_video)
    require 'net/http'
    require 'net/http/post/multipart'
    uri = URI('https://upload.wistia.com/')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Construct the request.
    request = Net::HTTP::Post::Multipart.new uri.request_uri, {
                                                                api_password: ENV['learnsignal_wistia_api_key'],
                                                                name: name,
                                                                project_id: @course_module_element.parent.parent.wistia_guid.to_s,

                                                                file: UploadIO.new(
                                                                    File.open(path_to_video),
                                                                    'application/octet-stream',
                                                                    File.basename(path_to_video)
                                                                )
                                                            }
    # Make it so!
    wistia_response = http.request(request)

    return wistia_response
  end


  def update
    set_related_cmes
    Rails.logger.debug "STARTING...."
    @course_module_element.assign_attributes(allowed_params)
    Rails.logger.debug "CONTINUING..."
    @course_module_element.valid?
    Rails.logger.debug "DEBUG: course_module_elements_controller#update about to save. Errors:#{@course_module_element.errors.inspect}."

    if @course_module_element.save
      flash[:success] = I18n.t('controllers.course_module_elements.update.flash.success')
      if params[:commit] == I18n.t('views.course_module_elements.form.save_and_add_another')
        redirect_to edit_course_module_element_url(@course_module_element.id)
      elsif params[:commit] == I18n.t('views.course_module_element_quizzes.form.preview_button')
        redirect_to @course_module_element.course_module_element_quiz.quiz_questions.last
      else
        redirect_to course_module_special_link(@course_module_element.course_module)
      end
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

  def create_empty_cme_flash_card_pack
    @course_module_element.build_course_module_element_flash_card_pack
    @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.build(content_type: 'Cards', sorting_order: 0)

    # flash cards
    @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_cards.build(sorting_order: 0)
    @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_cards.first.quiz_contents.build(sorting_order: 0)

    # flash quiz
    @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.build_flash_quiz(background_color: '#333333', foreground_color: '#eeeeee')
    @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_quiz.quiz_questions.build
    @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_quiz.quiz_questions.first.quiz_contents.build(sorting_order: 0)
    2.times do |counter|
      @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_quiz.quiz_questions.last.quiz_answers.build
      @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_quiz.quiz_questions.last.quiz_answers.last.quiz_contents.build(sorting_order: counter)
    end
  end

  def edit_empty_cme_flash_card_pack
    if @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.content_type == 'Cards'

      # flash quiz
      @flash_quiz = @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.build_flash_quiz
      @quiz_question = @flash_quiz.quiz_questions.build
      @quiz_question.quiz_contents.build(sorting_order: 0)
      2.times do |counter|
        @qa = @quiz_question.quiz_answers.build
        @qa.quiz_contents.build(sorting_order: counter)
      end
    elsif @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.content_type == 'Quiz'
      # build a flash card
      @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_cards.build(sorting_order: 0)
      @course_module_element.course_module_element_flash_card_pack.flash_card_stacks.first.flash_cards.first.quiz_contents.build(sorting_order: 0)
    end
  end

  def get_variables
    if params[:id].to_i > 0
      @course_module_element = CourseModuleElement.where(id: params[:id]).first
    end
    @tutors = User.all_tutors.all_in_order
    # todo reverse this when Philip asks for it
    #if action_name == 'new' || action_name == 'create'
    #  @raw_video_files = RawVideoFile.not_yet_assigned.all_in_order
    #else
      @raw_video_files = RawVideoFile.all_in_order
    #end
    @letters = ('A'..'Z').to_a
    @mathjax_required = true
  end

  def set_related_cmes
    if @course_module_element && @course_module_element.course_module
      @related_cmes = @course_module_element.course_module.course_module_elements.all_videos
    else
      @related_cmes = CourseModuleElement.none
    end
  end

  def allowed_params # todo
    if params[:course_module_element][:is_cme_flash_card_pack] == 't' || params[:course_module_element][:is_cme_flash_card_pack] == 'true'
      params[:course_module_element][:course_module_element_flash_card_pack_attributes][:flash_card_stacks_attributes].keys.each do |index|
        if params[:course_module_element][:course_module_element_flash_card_pack_attributes][:flash_card_stacks_attributes][index.to_s][:content_type] == 'Cards'
          params[:course_module_element][:course_module_element_flash_card_pack_attributes][:flash_card_stacks_attributes][index.to_s].delete(:flash_quiz_attributes)
        elsif params[:course_module_element][:course_module_element_flash_card_pack_attributes][:flash_card_stacks_attributes][index.to_s][:content_type] == 'Quiz'
          params[:course_module_element][:course_module_element_flash_card_pack_attributes][:flash_card_stacks_attributes][index.to_s].delete(:flash_cards_attributes)
        end
      end
    end

    Rails.logger.debug "DEBUG: Revised params: #{params.inspect}."

    params.require(:course_module_element).permit(
        :name,
        :name_url,
        :description,
        :estimated_time_in_seconds,
        :course_module_id,
        # :course_module_element_video_id,
        # :course_module_element_quiz_id,
        :sorting_order,
        :forum_topic_id,
        :tutor_id,
        :active,
        :related_quiz_id,
        :related_video_id,
        :is_video,
        :is_quiz,
        :seo_description,
        :seo_no_index,
        :is_cme_flash_card_pack,
        :number_of_questions,
        course_module_element_video_attributes: [
            :course_module_element_id,
            :id,
            :raw_video_file_id,
            :tags,
            :difficulty_level,
            # :estimated_study_time_seconds,
            :transcript,
            :video_id],
        course_module_element_quiz_attributes: [
            :id,
            :course_module_element_id,
            :number_of_questions,
            # :best_possible_score_retry,
            # :course_module_jumbo_quiz_id,
            :question_selection_strategy,
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
                    # :contains_mathjax,
                    # :contains_image,
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
                    # :correct,
                    :degree_of_wrongness,
                    :wrong_answer_explanation_text,
                    :wrong_answer_video_id,
                    :_destroy,
                    quiz_contents_attributes: [
                        :id,
                        :quiz_question_id,
                        :quiz_answer_id,
                        :text_content,
                        # :contains_mathjax,
                        # :contains_image,
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
                    # :contains_mathjax,
                    # :contains_image,
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
                :upload_updated_at
        ],
        course_module_element_flash_card_pack_attributes: [
                :id,
                :course_module_element_id,
                :background_color,
                :foreground_color,
                flash_card_stacks_attributes: [
                        :id,
                        :course_module_element_flash_card_pack_id,
                        :name,
                        :sorting_order,
                        :final_button_label,
                        :content_type,
                        :_destroy,
                        flash_cards_attributes: [
                                :id,
                                :flash_card_stack_id,
                                :sorting_order,
                                :_destroy,
                                quiz_contents_attributes: [
                                        :id,
                                        :text_content,
                                        #:contains_mathjax,
                                        #:contains_image,
                                        :sorting_order,
                                        :image,
                                        :image_file_name,
                                        :image_content_type,
                                        :image_file_size,
                                        :image_updated_at,
                                        :flash_card_id,
                                        :content_type,
                                        :_destroy
                                ]
                        ],
                        flash_quiz_attributes: [
                                :id,
                                :flash_card_stack_id,
                                :background_color,
                                :foreground_color,
                                quiz_questions_attributes: [
                                        :id,
                                        :flash_quiz_id,
                                        :course_module_element_quiz_id,
                                        :difficulty_level,
                                        :hints,
                                        :_destroy,
                                        quiz_answers_attributes: [
                                                :id,
                                                :quiz_question_id,
                                                :correct,
                                                :degree_of_wrongness,
                                                :wrong_answer_explanation_text,
                                                :wrong_answer_video_id,
                                                :_destroy,
                                                quiz_contents_attributes: [
                                                        :id,
                                                        :quiz_question_id,
                                                        :quiz_answer_id,
                                                        :text_content,
                                                        :contains_mathjax,
                                                        :contains_image,
                                                        :content_type,
                                                        :sorting_order,
                                                        :_destroy
                                                ]
                                        ],
                                        quiz_contents_attributes: [
                                                :id,
                                                :quiz_question_id,
                                                :quiz_answer_id,
                                                :text_content,
                                                :contains_mathjax,
                                                :contains_image,
                                                :content_type,
                                                :sorting_order,
                                                :_destroy
                                        ]
                                ]
                        ]
                ]
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
