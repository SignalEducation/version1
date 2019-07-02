puts '1'
CbeQuestionStatus.where(name: 'Complete').first_or_create!(name: 'Complete')
puts '*** Created'
CbeQuestionStatus.where(name: 'Unseen').first_or_create!(name: 'Unseen')
puts '*** 2 Created'
CbeQuestionStatus.where(name: 'Incomplete').first_or_create!(name: 'Incomplete')
puts '*** 3 Created'