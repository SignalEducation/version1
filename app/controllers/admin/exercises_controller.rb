class Admin::ExercisesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(exercise_corrections_access))
  end
  before_action :set_exercise, except: :index

  layout 'management'

  def index
    @exercises = Exercise.with_state(params[:state] || :submitted).paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      flash[:success] = I18n.t('controllers.exercises.update.flash.success')
      redirect_to admin_exercises_path
    else
      render action: :edit
    end
  end

  private

  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:correction)
  end
end
