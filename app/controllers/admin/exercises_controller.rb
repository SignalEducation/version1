# frozen_string_literal: true

module Admin
  class ExercisesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[exercise_corrections_access]) }
    before_action :set_user, only: %i[index new create]
    before_action :set_exercise, only: %i[show edit update]
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
