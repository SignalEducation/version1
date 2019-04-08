class ExercisesController < ApplicationController
  before_action :logged_in_required
  before_action :set_exercise, except: :index

  def index
    @exercises = current_user.exercises
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      @exercise.submit if @exercise.submission.present?
      redirect_to exercise_path(@exercise), notice: 'Submission successful. You will be notified when corrections become available.'
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
    unless @exercise.user_id == current_user.id
      redirect_to user_exercises_path(current_user)
    end
  end
end
