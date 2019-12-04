# frozen_string_literal: true

module CbeQuestionsHelper
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

  def question_title_class(question)
    case question.correct
    when true
      "<span style='color: #00b67B;' class='glyphicon glyphicon-ok pull-right'></span>".html_safe
    when false
      "<span style='color: #dc3545;' class='glyphicon glyphicon-remove pull-right'></span>".html_safe
    else
      "<span style='color: #f0ca28;' class='glyphicon glyphicon-pencil pull-right'></span>".html_safe
    end
  end

  def question_answer(answer)
    if answer.content['correct']
      "#{answer.content['text']} <span style='color: #00b67B;' class='glyphicon glyphicon-ok pull-right'></span>".html_safe
    elsif answer.content['correct'] == false
      "#{answer.content['text']} <span style='color: #dc3545;' class='glyphicon glyphicon-remove pull-right'></span>".html_safe
    else
      answer.content['text']
    end
  end

  private

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
