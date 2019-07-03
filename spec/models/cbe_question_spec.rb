require 'rails_helper'

RSpec.describe CbeQuestion, type: :model do

  cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
  cbe_section = CbeSection.create(name: 'Intro')
  cbe_queston = CbeMultipleChoiceQuestion.create()
end
