# frozen_string_literal: true

# A json response helper
module PracticeQuestions
  def new_practice_question_resource(last_resource, type, resource_id)
    last_resource = 0 if last_resource.nil?
    if type == 'exhibit'
      PracticeQuestion::Exhibit.new(sorting_order: last_resource + 1, practice_question_id: resource_id)
    else
      PracticeQuestion::Solution.new(sorting_order: last_resource + 1, practice_question_id: resource_id)
    end
  end
end
