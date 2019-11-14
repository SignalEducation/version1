# frozen_string_literal: true

module CbeQuestionsHelper
  def question_title(question)
    klass        = question_title_class(question)
    cbe_question = question.cbe_question

    tag.h6 class: 'text-gray2' do
      tag.div class: klass do
        "Question ##{cbe_question.sorting_order} - #{cbe_question.kind.humanize}(#{cbe_question.score})"
      end
    end
  end

  def question_corrected_link(question)
    button_tag question.cbe_question.kind.humanize,
               'class': 'btn btn-link', 'aria-controls': "collapse_#{question.id}",
               'aria-expanded': 'false', 'data-toggle': 'collapse',
               "data-target": "#collapse_#{question.id}"
  end

  def render_admin_answers(question)
    question_kind = question.cbe_question.kind
    partial       = admin_answers_partial(question_kind)

    render partial: partial, locals: { question: question, question_kind: question_kind }
  end

  private

  def question_title_class(question)
    case question.correct
    when true
      'text-green'
    when false
      'text-red'
    else
      'text-yellow'
    end
  end

  def admin_answers_partial(question_kind)
    case question_kind
    when 'open', 'spreadsheet'
      'admin/exercises/cbes_answers/open_answer'
    when 'fill_in_the_blank'
      'admin/exercises/cbes_answers/single_answer'
    when 'multiple_response', 'multiple_choice', 'drag_drop', 'dropdown_list'
      'admin/exercises/cbes_answers/multiple_answers'
    end
  end
end
