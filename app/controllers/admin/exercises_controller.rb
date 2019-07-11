class Admin::ExercisesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(exercise_corrections_access))
  end
  before_action :set_exercise, except: :index

  layout 'management'

  def index
    if request.post?
      @filters = params.slice(:state, :product, :corrector, :search)
      @exercises = Exercise.filter(@filters)
      case params[:state]
      when 'returned', 'all'
        @exercises = @exercises.order(created_at: :desc)
      else
        @exercises = @exercises.order(created_at: :asc)
      end
      @exercises = @exercises.paginate(per_page: 50, page: params[:page])
    else
      @filters = { state: 'submitted', product: '', corrector: '', search: '' }
      @exercises = Exercise.with_state(:submitted).
                            order(created_at: :asc).
                            paginate(per_page: 50, page: params[:page])
    end
  end

  def show
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      @exercise.return if @exercise.correction.present? && @exercise.correcting?
      redirect_to admin_exercises_path, notice: I18n.t('controllers.exercises.update.flash.success')
    else
      render action: :edit
    end
  end

  private

  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:correction, :corrector_id)
  end
end
