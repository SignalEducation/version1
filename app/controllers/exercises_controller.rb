class ExercisesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(student_user))
  end
  before_action :set_exercise, except: :index

  def index
    @exercises = current_user.exercises
  end

  def show
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to user_exercises_path(current_user), notice: 'Submission successful. You will be notified when corrections become available.'
    else
      render :new
    end
  end

  private

  def exercise_params
    params.require(:exercise).permit(:submission)
  end

  def set_exercise
    @exercise = Exercise.find(params[:id])
  end
end
