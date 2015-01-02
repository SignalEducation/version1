class RemoveSolutionToTheQuestionFromQuizQuestions < ActiveRecord::Migration
  def up
    print 'Migrating data: '
    QuizQuestion.where(solution_to_the_question: '').update_all(solution_to_the_question: 'Solution TBC')
    QuizQuestion.all.each do |question|
      QuizContent.where(quiz_solution_id: question.id).first_or_create!(
              text_content: question.solution_to_the_question,
              sorting_order: 1, content_type: 'text'
      ); print '.'
    end
    puts ' Done'
    remove_column :quiz_questions, :solution_to_the_question
  end

  def down
    add_column :quiz_questions, :solution_to_the_question, :text
    print 'Migrating data: '
    QuizQuestion.all.each do |question|
      if question.quiz_solutions.any?
        question.update_attributes(solution_to_the_question: question.quiz_solutions.map(&:text_content).join('::'))
        question.quiz_solutions.destroy_all
      end
      print '.'
    end
    puts ' Done'
  end
end
