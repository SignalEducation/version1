# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :logged_in_required
  before_action :set_exercise, except: :index

  def index
    @exercises = current_user.exercises
    @exercise  = @exercises.last
  end

  def edit; end

  def update
    if @exercise.update(exercise_params)
      if @exercise.submission.present?
        @exercise.submit
        redirect_to exercise_path(@exercise), notice: 'Submission successful. You will be notified when corrections become available.'
      else
        flash[:error] = 'Submission unsuccessful. You must upload a submission file.'
        redirect_to edit_exercise_path(@exercise)
      end
    else
      flash[:error] = 'Unable to upload your submission'
      redirect_to edit_exercise_path(@exercise)
    end
  end

  private

  def exercise_params
    params.require(:exercise).permit(:submission)
  end

  def set_exercise
    @exercise = Exercise.find(params[:id])
    redirect_to user_exercises_path(current_user) if @exercise.user_id != current_user.id
  end
end
