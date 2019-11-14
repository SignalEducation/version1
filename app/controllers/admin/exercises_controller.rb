# frozen_string_literal: true

module Admin
  class ExercisesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[exercise_corrections_access]) }
    before_action :set_user, only: %i[index new create correct_cbe]
    before_action :set_exercise, only: %i[show edit update return_cbe]
    before_action :management_layout

    def index
      @filters = { state: 'submitted', product: '', corrector: '', search: '' }

      if request.post?
        @exercises = Exercise.where(nil)

        filtering_params(params).each do |key, value|
          @exercises = @exercises.public_send(key, value) if value.present?
          @filters[key] = value
        end

        case params[:state]
        when 'returned', 'all'
          @exercises = @exercises.order(created_at: :desc)
        else
          @exercises = @exercises.order(created_at: :asc)
        end
        @exercises = @exercises.paginate(per_page: 50, page: params[:page])
      else
        @exercises = Exercise.with_state(:submitted).
                       order(created_at: :asc).
                       paginate(per_page: 50, page: params[:page])
      end
    end

    def show; end

    def new
      @exercise = @user.exercises.build
    end

    def create
      @exercise = @user.exercises.build(exercise_params)

      if @exercise.save
        flash[:success] = 'Pending exercise successfully created'
        redirect_to admin_user_exercises_path(@user)
      else
        render :new
      end
    end

    def edit; end

    def update
      if @exercise.update(exercise_params)
        @exercise.return if @exercise.correction.present? && @exercise.correcting?
        flash[:success] = I18n.t('controllers.exercises.update.flash.success')
        redirect_to admin_exercises_path
      else
        render action: :edit
      end
    end

    def generate_daily_summary
      Order.send_daily_orders_update
      redirect_to admin_exercises_path, notice: 'Daily summary sent to Slack'
    end

    # CBE Exercise
    def correct_cbe
      @exercise = Exercise.
                    includes(cbe_user_log: [questions: [:cbe_question]]).
                    find(params[:id])
      @cbe_user_log = @exercise.cbe_user_log
      @cbe          = @cbe_user_log.cbe

      @exercise.correct
    end

    def cbe_user_question_update
      @question = Cbe::UserQuestion.find(params[:question_id])
      @user_log = Cbe::UserLog.find(@question.cbe_user_log_id)
      @response = 'Question was updated.'

      ActiveRecord::Base.transaction do
        @question.update(score: params[:score], educator_comment: params[:educator_comment])
        @user_log.update(status: 'corrected')
      end

      respond_to do |format|
        format.js
      end
    end

    def return_cbe
      @cbe_user_log = @exercise.cbe_user_log
      @cbe          = @cbe_user_log.cbe

      if @exercise.cbe_user_log.status == 'corrected' && @exercise.return
        flash[:success] = I18n.t('controllers.exercises.update.flash.success')
        redirect_to admin_exercises_path
      else
        render action: :correct_cbe
      end
    end
    # CBE Exercise

    private

    def filtering_params(params)
      params.slice(:state, :product, :corrector, :search)
    end

    def set_exercise
      @exercise = Exercise.find(params[:id])
    end

    def set_user
      @user = User.find_by(id: params[:user_id])
    end

    def exercise_params
      params.require(:exercise).permit(
        :correction, :corrector_id, :submission, :product_id
      )
    end
  end
end
