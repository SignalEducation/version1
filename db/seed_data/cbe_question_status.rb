CbeQuestionStatus.where(name: 'Complete',).first_or_create!(name: 'Complete')
CbeQuestionStatus.where(name: 'Unseen').first_or_create!(name: 'Unseen')
CbeQuestionStatus.where(name: 'Incomplete').first_or_create!(name: 'Incomplete')
