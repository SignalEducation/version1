# load me while with a Rails console with:
#> load 'tmp/course_content_data.rb'


CourseSection.where(id: 1).first_or_create!(subject_course_id: 1, name: "Tuition", name_url: "tuition", sorting_order: 1, active: true, counts_towards_completion: true)
CourseSection.where(id: 2).first_or_create!(subject_course_id: 1, name: "Question Bank", name_url: "question-bank", sorting_order: 1, active: true, counts_towards_completion: true)

CourseModule.where(id: 1).first_or_create!(subject_course_id: 1, course_section_id: 1, name: "Introduction", name_url: "introduction", description: "Intro", sorting_order: 1, estimated_time_in_seconds: 360, active: true)
CourseModule.where(id: 2).first_or_create!(subject_course_id: 1, course_section_id: 1, name: "Professional Skills", name_url: "professional-skills", description: "sdf", sorting_order: 1, estimated_time_in_seconds: 299, active: true)
CourseModule.where(id: 3).first_or_create!(subject_course_id: 1, course_section_id: 1, name: "Leadership", name_url: "leadership", description: "sdf", sorting_order: 1, estimated_time_in_seconds: 299, active: true)

CourseModule.where(id: 4).first_or_create!(subject_course_id: 1, course_section_id: 2, name: "Governance", name_url: "governance", description: "This module discusses Environmental Impact Assessment.", sorting_order: 1, estimated_time_in_seconds: 0, active: true)
CourseModule.where(id: 5).first_or_create!(subject_course_id: 1, course_section_id: 2, name: "Strategy", name_url: "strategy", description: "This module discusses Environmental Impact Assessment.", sorting_order: 1, estimated_time_in_seconds: 0, active: true)
CourseModule.where(id: 6).first_or_create!(subject_course_id: 1, course_section_id: 2, name: "Risk", name_url: "risk", description: "This module discusses Environmental Impact Assessment.", sorting_order: 1, estimated_time_in_seconds: 0, active: true)


CourseModuleElement.where(id: 1).first_or_create!(name: "Mergers 101 Video", name_url: "mergers-101", description: "Sed ut perspiciatis unde omnis iste natus error si...", estimated_time_in_seconds: 100, course_module_id: 1, sorting_order: 1, is_video: true, is_quiz: false, active: true, number_of_questions: 3, available_on_trial: true)
CourseModuleElement.where(id: 2).first_or_create!(name: "Mergers 102 Quiz", name_url: "mergers-102", description: "Lorem ipsum dolor sit amet, consectetur adipiscing...", estimated_time_in_seconds: 100, course_module_id: 1, sorting_order: 2, is_video: false, is_quiz: true, active: true, number_of_questions: 3, available_on_trial: true, related_course_module_element_id: 1)
CourseModuleElement.where(id: 3).first_or_create!(name: "Mergers 103 Video", name_url: "mergers-103", description: "What is a Merger", estimated_time_in_seconds: 180, course_module_id: 1, sorting_order: 2, is_video: true, is_quiz: false, active: true, number_of_questions: 3, available_on_trial: false)
CourseModuleElement.where(id: 4).first_or_create!(name: "Mergers 104 Quiz", name_url: "mergers-104", description: "This is the description", estimated_time_in_seconds: 180, course_module_id: 1, sorting_order: 1, is_video: false, is_quiz: true, active: true, number_of_questions: 3, available_on_trial: false)

CourseModuleElement.where(id: 5).first_or_create!(name: "Quant Methods 101 Video", name_url: "quant-methods-101-video", description: "This is an introduction", estimated_time_in_seconds: 180, course_module_id: 2, sorting_order: 5, is_video: true, is_quiz: false, active: true, number_of_questions: 3, available_on_trial: true)
CourseModuleElement.where(id: 6).first_or_create!(name: "Quant Methods 102 Quiz", name_url: "quant-methods-102-quiz", description: "This is an introduction", estimated_time_in_seconds: 180, course_module_id: 2, sorting_order: 5, is_video: false, is_quiz: true, active: true, number_of_questions: 3, available_on_trial: true)
CourseModuleElement.where(id: 7).first_or_create!(name: "Quant Methods 103 Video", name_url: "quant-methods-103-video", description: "This is an introduction", estimated_time_in_seconds: 180, course_module_id: 2, sorting_order: 5, is_video: true, is_quiz: false, active: true, number_of_questions: 3, available_on_trial: true)
CourseModuleElement.where(id: 8).first_or_create!(name: "Business Organisation 101 Video", name_url: "business-organisation-101-video", description: "This is the intro quiz. Best of luck!", estimated_time_in_seconds: 900, course_module_id: 2, sorting_order: 6, is_video: true, is_quiz: false, active: true, number_of_questions: 3, available_on_trial: false)
CourseModuleElement.where(id: 9).first_or_create!(name: "Business Organisation 102 Quiz", name_url: "business-organisation-102-quiz", description: "sdfasdf456645", estimated_time_in_seconds: 99, course_module_id: 2, sorting_order: 7, is_video: false, is_quiz: true, active: true, number_of_questions: 3, available_on_trial: false)
CourseModuleElement.where(id: 10).first_or_create!(name: "Business Organisation 103 Video", name_url: "business-organisation-103-video", description: "dsfa", estimated_time_in_seconds: 200, course_module_id: 2, sorting_order: 8, is_video: true, is_quiz: false, active: true, number_of_questions: 3, available_on_trial: false)

CourseModuleElementVideo.where(id: 1).first_or_create!(course_module_element_id: 1, vimeo_guid: '326836832', duration: 200)
CourseModuleElementVideo.where(id: 2).first_or_create!(course_module_element_id: 3, vimeo_guid: '326865619', duration: 200)
CourseModuleElementVideo.where(id: 3).first_or_create!(course_module_element_id: 5, vimeo_guid: '326872692', duration: 200)
CourseModuleElementVideo.where(id: 4).first_or_create!(course_module_element_id: 7, vimeo_guid: '326836832', duration: 200)
CourseModuleElementVideo.where(id: 5).first_or_create!(course_module_element_id: 8, vimeo_guid: '326865619', duration: 200)
CourseModuleElementVideo.where(id: 5).first_or_create!(course_module_element_id: 10, vimeo_guid: '326872692', duration: 200)

CourseModuleElementQuiz.where(id: 1).first_or_create!(course_module_element_id: 2, number_of_questions: 10, question_selection_strategy: "random")
CourseModuleElementQuiz.where(id: 2).first_or_create!(course_module_element_id: 4, number_of_questions: 10, question_selection_strategy: "random")
CourseModuleElementQuiz.where(id: 3).first_or_create!(course_module_element_id: 6, number_of_questions: 10, question_selection_strategy: "random")
CourseModuleElementQuiz.where(id: 4).first_or_create!(course_module_element_id: 9, number_of_questions: 10, question_selection_strategy: "random")

CourseModuleElementResource.where(id: 1).first_or_create!(course_module_element_id: 1, name: "Climate system notes", web_url: "http://en.wikipedia.org/wiki/Climate")

# Belong to CME 2
QuizQuestion.where(id: 1).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 2).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 3).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 4).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 5).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 6).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 7).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 8).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 9).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
QuizQuestion.where(id: 10).first_or_create!(course_module_element_quiz_id: 1, course_module_element_id: 2)
# Belong to CME 4
QuizQuestion.where(id: 11).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 12).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 13).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 14).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 15).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 16).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 17).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 18).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 19).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
QuizQuestion.where(id: 20).first_or_create!(course_module_element_quiz_id: 2, course_module_element_id: 4)
# Belong to CME 6
QuizQuestion.where(id: 21).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 22).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 23).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 24).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 25).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 26).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 27).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 28).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 29).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
QuizQuestion.where(id: 30).first_or_create!(course_module_element_quiz_id: 3, course_module_element_id: 6)
# Belong to CME 4
QuizQuestion.where(id: 31).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 32).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 33).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 34).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 35).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 36).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 37).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 38).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 39).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)
QuizQuestion.where(id: 40).first_or_create!(course_module_element_quiz_id: 4, course_module_element_id: 9)

# Belong to CME 2
#Belong to Question 1
QuizAnswer.where(id: 1).first_or_create!(quiz_question_id: 1, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 2).first_or_create!(quiz_question_id: 1, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 3).first_or_create!(quiz_question_id: 1, degree_of_wrongness: "correct")
QuizAnswer.where(id: 4).first_or_create!(quiz_question_id: 1, degree_of_wrongness: "incorrect")
#Belong to Question 2
QuizAnswer.where(id: 5).first_or_create!(quiz_question_id: 2, degree_of_wrongness: "correct")
QuizAnswer.where(id: 6).first_or_create!(quiz_question_id: 2, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 7).first_or_create!(quiz_question_id: 2, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 8).first_or_create!(quiz_question_id: 2, degree_of_wrongness: "incorrect")
#Belong to Question 3
QuizAnswer.where(id: 9).first_or_create!(quiz_question_id: 3, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 10).first_or_create!(quiz_question_id: 3, degree_of_wrongness: "correct")
QuizAnswer.where(id: 11).first_or_create!(quiz_question_id: 3, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 12).first_or_create!(quiz_question_id: 3, degree_of_wrongness: "incorrect")
#Belong to Question 4
QuizAnswer.where(id: 13).first_or_create!(quiz_question_id: 4, degree_of_wrongness: "correct")
QuizAnswer.where(id: 14).first_or_create!(quiz_question_id: 4, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 15).first_or_create!(quiz_question_id: 4, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 16).first_or_create!(quiz_question_id: 4, degree_of_wrongness: "incorrect")
#Belong to Question 5
QuizAnswer.where(id: 17).first_or_create!(quiz_question_id: 5, degree_of_wrongness: "correct")
QuizAnswer.where(id: 18).first_or_create!(quiz_question_id: 5, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 19).first_or_create!(quiz_question_id: 5, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 20).first_or_create!(quiz_question_id: 5, degree_of_wrongness: "incorrect")
#Belong to Question 6
QuizAnswer.where(id: 21).first_or_create!(quiz_question_id: 6, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 22).first_or_create!(quiz_question_id: 6, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 23).first_or_create!(quiz_question_id: 6, degree_of_wrongness: "correct")
QuizAnswer.where(id: 24).first_or_create!(quiz_question_id: 6, degree_of_wrongness: "incorrect")
#Belong to Question 7
QuizAnswer.where(id: 25).first_or_create!(quiz_question_id: 7, degree_of_wrongness: "correct")
QuizAnswer.where(id: 26).first_or_create!(quiz_question_id: 7, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 27).first_or_create!(quiz_question_id: 7, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 28).first_or_create!(quiz_question_id: 7, degree_of_wrongness: "incorrect")
#Belong to Question 8
QuizAnswer.where(id: 29).first_or_create!(quiz_question_id: 8, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 30).first_or_create!(quiz_question_id: 8, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 31).first_or_create!(quiz_question_id: 8, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 32).first_or_create!(quiz_question_id: 8, degree_of_wrongness: "correct")
#Belong to Question 9
QuizAnswer.where(id: 33).first_or_create!(quiz_question_id: 9, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 34).first_or_create!(quiz_question_id: 9, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 35).first_or_create!(quiz_question_id: 9, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 36).first_or_create!(quiz_question_id: 9, degree_of_wrongness: "correct")
#Belong to Question 10
QuizAnswer.where(id: 37).first_or_create!(quiz_question_id: 10, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 38).first_or_create!(quiz_question_id: 10, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 39).first_or_create!(quiz_question_id: 10, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 40).first_or_create!(quiz_question_id: 10, degree_of_wrongness: "correct")

# Belong to CME 2
#Belong to Question 11
QuizAnswer.where(id: 41).first_or_create!(quiz_question_id: 11, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 42).first_or_create!(quiz_question_id: 11, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 43).first_or_create!(quiz_question_id: 11, degree_of_wrongness: "correct")
QuizAnswer.where(id: 44).first_or_create!(quiz_question_id: 11, degree_of_wrongness: "incorrect")
#Belong to Question 12
QuizAnswer.where(id: 45).first_or_create!(quiz_question_id: 12, degree_of_wrongness: "correct")
QuizAnswer.where(id: 46).first_or_create!(quiz_question_id: 12, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 47).first_or_create!(quiz_question_id: 12, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 48).first_or_create!(quiz_question_id: 12, degree_of_wrongness: "incorrect")
#Belong to Question 13
QuizAnswer.where(id: 49).first_or_create!(quiz_question_id: 13, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 50).first_or_create!(quiz_question_id: 13, degree_of_wrongness: "correct")
QuizAnswer.where(id: 51).first_or_create!(quiz_question_id: 13, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 52).first_or_create!(quiz_question_id: 13, degree_of_wrongness: "incorrect")
#Belong to Question 14
QuizAnswer.where(id: 53).first_or_create!(quiz_question_id: 14, degree_of_wrongness: "correct")
QuizAnswer.where(id: 54).first_or_create!(quiz_question_id: 14, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 55).first_or_create!(quiz_question_id: 14, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 56).first_or_create!(quiz_question_id: 14, degree_of_wrongness: "incorrect")
#Belong to Question 15
QuizAnswer.where(id: 57).first_or_create!(quiz_question_id: 15, degree_of_wrongness: "correct")
QuizAnswer.where(id: 58).first_or_create!(quiz_question_id: 15, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 59).first_or_create!(quiz_question_id: 15, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 60).first_or_create!(quiz_question_id: 15, degree_of_wrongness: "incorrect")
#Belong to Question 16
QuizAnswer.where(id: 61).first_or_create!(quiz_question_id: 16, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 62).first_or_create!(quiz_question_id: 16, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 63).first_or_create!(quiz_question_id: 16, degree_of_wrongness: "correct")
QuizAnswer.where(id: 64).first_or_create!(quiz_question_id: 16, degree_of_wrongness: "incorrect")
#Belong to Question 17
QuizAnswer.where(id: 65).first_or_create!(quiz_question_id: 17, degree_of_wrongness: "correct")
QuizAnswer.where(id: 66).first_or_create!(quiz_question_id: 17, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 67).first_or_create!(quiz_question_id: 17, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 68).first_or_create!(quiz_question_id: 17, degree_of_wrongness: "incorrect")
#Belong to Question 18
QuizAnswer.where(id: 69).first_or_create!(quiz_question_id: 18, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 70).first_or_create!(quiz_question_id: 18, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 71).first_or_create!(quiz_question_id: 18, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 72).first_or_create!(quiz_question_id: 18, degree_of_wrongness: "correct")
#Belong to Question 19
QuizAnswer.where(id: 73).first_or_create!(quiz_question_id: 19, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 74).first_or_create!(quiz_question_id: 19, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 75).first_or_create!(quiz_question_id: 19, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 76).first_or_create!(quiz_question_id: 19, degree_of_wrongness: "correct")
#Belong to Question 20
QuizAnswer.where(id: 77).first_or_create!(quiz_question_id: 20, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 78).first_or_create!(quiz_question_id: 20, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 79).first_or_create!(quiz_question_id: 20, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 80).first_or_create!(quiz_question_id: 20, degree_of_wrongness: "correct")

# Belong to CME 3
#Belong to Question 21
QuizAnswer.where(id: 81).first_or_create!(quiz_question_id: 21, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 82).first_or_create!(quiz_question_id: 21, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 83).first_or_create!(quiz_question_id: 21, degree_of_wrongness: "correct")
QuizAnswer.where(id: 84).first_or_create!(quiz_question_id: 21, degree_of_wrongness: "incorrect")
#Belong to Question 22
QuizAnswer.where(id: 85).first_or_create!(quiz_question_id: 22, degree_of_wrongness: "correct")
QuizAnswer.where(id: 86).first_or_create!(quiz_question_id: 22, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 87).first_or_create!(quiz_question_id: 22, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 88).first_or_create!(quiz_question_id: 22, degree_of_wrongness: "incorrect")
#Belong to Question 23
QuizAnswer.where(id: 89).first_or_create!(quiz_question_id: 23, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 90).first_or_create!(quiz_question_id: 23, degree_of_wrongness: "correct")
QuizAnswer.where(id: 91).first_or_create!(quiz_question_id: 23, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 52).first_or_create!(quiz_question_id: 23, degree_of_wrongness: "incorrect")
#Belong to Question 24
QuizAnswer.where(id: 93).first_or_create!(quiz_question_id: 24, degree_of_wrongness: "correct")
QuizAnswer.where(id: 94).first_or_create!(quiz_question_id: 24, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 95).first_or_create!(quiz_question_id: 24, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 96).first_or_create!(quiz_question_id: 24, degree_of_wrongness: "incorrect")
#Belong to Question 25
QuizAnswer.where(id: 97).first_or_create!(quiz_question_id: 25, degree_of_wrongness: "correct")
QuizAnswer.where(id: 98).first_or_create!(quiz_question_id: 25, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 99).first_or_create!(quiz_question_id: 25, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 100).first_or_create!(quiz_question_id:25, degree_of_wrongness: "incorrect")
#Belong to Question 26
QuizAnswer.where(id: 101).first_or_create!(quiz_question_id: 26, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 102).first_or_create!(quiz_question_id: 26, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 103).first_or_create!(quiz_question_id: 26, degree_of_wrongness: "correct")
QuizAnswer.where(id: 104).first_or_create!(quiz_question_id: 26, degree_of_wrongness: "incorrect")
#Belong to Question 27
QuizAnswer.where(id: 105).first_or_create!(quiz_question_id: 27, degree_of_wrongness: "correct")
QuizAnswer.where(id: 106).first_or_create!(quiz_question_id: 27, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 107).first_or_create!(quiz_question_id: 27, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 108).first_or_create!(quiz_question_id: 27, degree_of_wrongness: "incorrect")
#Belong to Question 28
QuizAnswer.where(id: 109).first_or_create!(quiz_question_id: 28, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 110).first_or_create!(quiz_question_id: 28, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 111).first_or_create!(quiz_question_id: 28, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 112).first_or_create!(quiz_question_id: 28, degree_of_wrongness: "correct")
#Belong to Question 29
QuizAnswer.where(id: 113).first_or_create!(quiz_question_id: 29, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 114).first_or_create!(quiz_question_id: 29, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 115).first_or_create!(quiz_question_id: 29, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 116).first_or_create!(quiz_question_id: 29, degree_of_wrongness: "correct")
#Belong to Question 30
QuizAnswer.where(id: 117).first_or_create!(quiz_question_id: 30, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 118).first_or_create!(quiz_question_id: 30, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 119).first_or_create!(quiz_question_id: 30, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 120).first_or_create!(quiz_question_id: 30, degree_of_wrongness: "correct")

# Belong to CME 4
#Belong to Question 31
QuizAnswer.where(id: 121).first_or_create!(quiz_question_id: 31, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 122).first_or_create!(quiz_question_id: 31, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 123).first_or_create!(quiz_question_id: 31, degree_of_wrongness: "correct")
QuizAnswer.where(id: 124).first_or_create!(quiz_question_id: 31, degree_of_wrongness: "incorrect")
#Belong to Question 32
QuizAnswer.where(id: 125).first_or_create!(quiz_question_id: 32, degree_of_wrongness: "correct")
QuizAnswer.where(id: 126).first_or_create!(quiz_question_id: 32, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 127).first_or_create!(quiz_question_id: 32, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 128).first_or_create!(quiz_question_id: 32, degree_of_wrongness: "incorrect")
#Belong to Question 33
QuizAnswer.where(id: 129).first_or_create!(quiz_question_id: 33, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 130).first_or_create!(quiz_question_id: 33, degree_of_wrongness: "correct")
QuizAnswer.where(id: 131).first_or_create!(quiz_question_id: 33, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 132).first_or_create!(quiz_question_id: 33, degree_of_wrongness: "incorrect")
#Belong to Question 34
QuizAnswer.where(id: 133).first_or_create!(quiz_question_id: 34, degree_of_wrongness: "correct")
QuizAnswer.where(id: 134).first_or_create!(quiz_question_id: 34, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 135).first_or_create!(quiz_question_id: 34, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 136).first_or_create!(quiz_question_id: 34, degree_of_wrongness: "incorrect")
#Belong to Question 35
QuizAnswer.where(id: 137).first_or_create!(quiz_question_id: 35, degree_of_wrongness: "correct")
QuizAnswer.where(id: 138).first_or_create!(quiz_question_id: 35, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 139).first_or_create!(quiz_question_id: 35, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 140).first_or_create!(quiz_question_id:35, degree_of_wrongness: "incorrect")
#Belong to Question 36
QuizAnswer.where(id: 141).first_or_create!(quiz_question_id: 36, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 142).first_or_create!(quiz_question_id: 36, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 143).first_or_create!(quiz_question_id: 36, degree_of_wrongness: "correct")
QuizAnswer.where(id: 144).first_or_create!(quiz_question_id: 36, degree_of_wrongness: "incorrect")
#Belong to Question 37
QuizAnswer.where(id: 145).first_or_create!(quiz_question_id: 37, degree_of_wrongness: "correct")
QuizAnswer.where(id: 146).first_or_create!(quiz_question_id: 37, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 147).first_or_create!(quiz_question_id: 37, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 148).first_or_create!(quiz_question_id: 37, degree_of_wrongness: "incorrect")
#Belong to Question 38
QuizAnswer.where(id: 149).first_or_create!(quiz_question_id: 38, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 150).first_or_create!(quiz_question_id: 38, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 151).first_or_create!(quiz_question_id: 38, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 152).first_or_create!(quiz_question_id: 38, degree_of_wrongness: "correct")
#Belong to Question 39
QuizAnswer.where(id: 153).first_or_create!(quiz_question_id: 39, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 154).first_or_create!(quiz_question_id: 39, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 155).first_or_create!(quiz_question_id: 39, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 156).first_or_create!(quiz_question_id: 39, degree_of_wrongness: "correct")
#Belong to Question 40
QuizAnswer.where(id: 157).first_or_create!(quiz_question_id: 40, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 158).first_or_create!(quiz_question_id: 40, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 159).first_or_create!(quiz_question_id: 40, degree_of_wrongness: "incorrect")
QuizAnswer.where(id: 160).first_or_create!(quiz_question_id: 40, degree_of_wrongness: "correct")

# Belong to Quiz 1
# Belong to Questions 1
QuizContent.where(id: 1).first_or_create!(quiz_question_id: 1, quiz_answer_id: nil, text_content: "Exchange traded funds transform the performance of...",  sorting_order: 0)
QuizContent.where(id: 2).first_or_create!(quiz_question_id: nil, quiz_answer_id: 1, text_content: "Exchange traded funds after deductions pass throug...",  sorting_order: 0)
QuizContent.where(id: 3).first_or_create!(quiz_question_id: nil, quiz_answer_id: 2, text_content: "Exchange traded funds after deductions pass throug...",  sorting_order: 0)
QuizContent.where(id: 4).first_or_create!(quiz_question_id: nil, quiz_answer_id: 3, text_content: "This is another question",  sorting_order: 0)
QuizContent.where(id: 5).first_or_create!(quiz_question_id: nil, quiz_answer_id: 4, text_content: 'Test',  sorting_order: 0, image_file_name: "01-home-NEWBANNER.jpg", image_content_type: "image/jpeg", image_file_size: 470131, image_updated_at: "2014-12-16 14:37:50")
# Belong to Questions 2
QuizContent.where(id: 6).first_or_create!(quiz_question_id: 2, quiz_answer_id: nil, text_content: "This is the question",  sorting_order: 0)
QuizContent.where(id: 7).first_or_create!(quiz_question_id: nil, quiz_answer_id: 5, text_content: "The is the first wrong answer",  sorting_order: 0)
QuizContent.where(id: 8).first_or_create!(quiz_question_id: nil, quiz_answer_id: 6, text_content: 'Test',  sorting_order: 100, image_file_name: "Calvin___Hobbes_4.jpg", image_content_type: "image/jpeg", image_file_size: 1106277, image_updated_at: "2014-12-12 15:47:27")
QuizContent.where(id: 9).first_or_create!(quiz_question_id: nil, quiz_answer_id: 7, text_content: "Another wrong", sorting_order: 0)
QuizContent.where(id: 10).first_or_create!(quiz_question_id: nil, quiz_answer_id: 8, text_content: "Final wrong answer",  sorting_order: 0)
# Belong to Questions 3
QuizContent.where(id: 11).first_or_create!(quiz_question_id: 3, quiz_answer_id: nil, text_content: "(math)a^2 + b^2 = c^2(/math)",  sorting_order: 0)
QuizContent.where(id: 12).first_or_create!(quiz_question_id: nil, quiz_answer_id: 9, text_content: "Because I just am",  sorting_order: 1)
QuizContent.where(id: 13).first_or_create!(quiz_question_id: nil, quiz_answer_id: 10, text_content: "Because I was born that way",  sorting_order: 2)
QuizContent.where(id: 14).first_or_create!(quiz_question_id: nil, quiz_answer_id: 11, text_content: "Because I am happy",  sorting_order: 3)
QuizContent.where(id: 15).first_or_create!(quiz_question_id: nil, quiz_answer_id: 12, text_content: "Because I was hit on the head!",  sorting_order: 4)
# Belong to Questions 4
QuizContent.where(id: 16).first_or_create!(quiz_question_id: 4, quiz_answer_id: nil, text_content: "Why am I crazy?",  sorting_order: 1)
QuizContent.where(id: 17).first_or_create!(quiz_question_id: nil, quiz_answer_id: 13, text_content: 'Test', sorting_order: 100)
QuizContent.where(id: 18).first_or_create!(quiz_question_id: nil, quiz_answer_id: 14, text_content: "this page mockup so awesome",  sorting_order: 100)
QuizContent.where(id: 19).first_or_create!(quiz_question_id: nil, quiz_answer_id: 15, text_content: "Conn",  sorting_order: 0)
QuizContent.where(id: 20).first_or_create!(quiz_question_id: nil, quiz_answer_id: 16, text_content: "xyz",  sorting_order: 0)
# Belong to Questions 5
QuizContent.where(id: 21).first_or_create!(quiz_question_id: 5, quiz_answer_id: 17, text_content: "James",  sorting_order: 0)
QuizContent.where(id: 22).first_or_create!(quiz_question_id: nil, quiz_answer_id: 18, text_content: "Philip",  sorting_order: 0)
QuizContent.where(id: 23).first_or_create!(quiz_question_id: nil, quiz_answer_id: 19, text_content: "my name is hat", sorting_order: 0)
QuizContent.where(id: 24).first_or_create!(quiz_question_id: nil, quiz_answer_id: 20, text_content: "Answer a",  sorting_order: 0)
QuizContent.where(id: 25).first_or_create!(quiz_question_id: nil, quiz_answer_id: 21, text_content: "Answer b",  sorting_order: 0)
# Belong to Questions 6
QuizContent.where(id: 26).first_or_create!(quiz_question_id: 6, quiz_answer_id: nil, text_content: "Answer c",  sorting_order: 0)
QuizContent.where(id: 27).first_or_create!(quiz_question_id: nil, quiz_answer_id: 20, text_content: "Answer d",  sorting_order: 0)
QuizContent.where(id: 28).first_or_create!(quiz_question_id: nil, quiz_answer_id: 21, text_content: "How old are you?",  sorting_order: 0)
QuizContent.where(id: 29).first_or_create!(quiz_question_id: nil, quiz_answer_id: 22, text_content: "(math)A^2(/math)",  sorting_order: 100)
QuizContent.where(id: 30).first_or_create!(quiz_question_id: nil, quiz_answer_id: 23, text_content: "There are no deductions in derivative contracts an...",  sorting_order: 1, quiz_solution_id: 1)
# Belong to Questions 7
QuizContent.where(id: 31).first_or_create!(quiz_question_id: 7, quiz_answer_id: nil, text_content: "This is the solution",  sorting_order: 1, quiz_solution_id: 2)
QuizContent.where(id: 32).first_or_create!(quiz_question_id: nil, quiz_answer_id: 24, text_content: "Due to genetic mishaps I was born this way. ",  sorting_order: 1, quiz_solution_id: 3)
QuizContent.where(id: 33).first_or_create!(quiz_question_id: nil, quiz_answer_id: 25, text_content: "Conn is my name",  sorting_order: 1, quiz_solution_id: 4)
QuizContent.where(id: 34).first_or_create!(quiz_question_id: nil, quiz_answer_id: 26, text_content: "This is solution",  sorting_order: 1, quiz_solution_id: 5)
QuizContent.where(id: 35).first_or_create!(quiz_question_id: nil, quiz_answer_id: 27, text_content: "4",  sorting_order: 1)
# Belong to Questions 8
QuizContent.where(id: 36).first_or_create!(quiz_question_id: 8, quiz_answer_id: nil, text_content: "2",  sorting_order: 2)
QuizContent.where(id: 37).first_or_create!(quiz_question_id: nil, quiz_answer_id: 23, text_content: "5",  sorting_order: 3)
QuizContent.where(id: 38).first_or_create!(quiz_question_id: nil, quiz_answer_id: 24, text_content: "6",  sorting_order: 4)
QuizContent.where(id: 39).first_or_create!(quiz_question_id: nil, quiz_answer_id: 25, text_content: "How many components in a climate system?",  sorting_order: 1)
QuizContent.where(id: 40).first_or_create!(quiz_question_id: nil, quiz_answer_id: 26, text_content: "The answer is 5",  sorting_order: 1, quiz_solution_id: 6)
# Belong to Questions 9
QuizContent.where(id: 41).first_or_create!(quiz_question_id: 9, quiz_answer_id: nil, text_content: "Atmosphere",  sorting_order: 1)
QuizContent.where(id: 42).first_or_create!(quiz_question_id: nil, quiz_answer_id: 27, text_content: "Stratosphere",  sorting_order: 2)
QuizContent.where(id: 43).first_or_create!(quiz_question_id: nil, quiz_answer_id: 28, text_content: "Ozone Layer",  sorting_order: 3)
QuizContent.where(id: 44).first_or_create!(quiz_question_id: nil, quiz_answer_id: 29, text_content: "Clouds",  sorting_order: 4)
QuizContent.where(id: 45).first_or_create!(quiz_question_id: nil, quiz_answer_id: 30, text_content: "Which of the following is a component?",  sorting_order: 1)
# Belong to Questions 10
QuizContent.where(id: 46).first_or_create!(quiz_question_id: 10, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: 7)
QuizContent.where(id: 47).first_or_create!(quiz_question_id: nil, quiz_answer_id: 31, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 48).first_or_create!(quiz_question_id: nil, quiz_answer_id: 32, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 49).first_or_create!(quiz_question_id: nil, quiz_answer_id: 33, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 50).first_or_create!(quiz_question_id: nil, quiz_answer_id: 34, text_content: "A",  sorting_order: 0)

# Belong to CME 1
# Belong to Quiz 2

# Belong to Questions 11
QuizContent.where(id: 51).first_or_create!(quiz_question_id: 11, quiz_answer_id: nil, text_content: "Question 1",  sorting_order: 0)
QuizContent.where(id: 52).first_or_create!(quiz_question_id: nil, quiz_answer_id: 35, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
QuizContent.where(id: 53).first_or_create!(quiz_question_id: nil, quiz_answer_id: 36, text_content: 'Test', sorting_order: 100, image_file_name: "arms_up12.png", image_content_type: "image/png", image_file_size: 38661, image_updated_at: "2015-01-08 17:37:52", quiz_solution_id: nil)
QuizContent.where(id: 54).first_or_create!(quiz_question_id: nil, quiz_answer_id: 37, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
QuizContent.where(id: 55).first_or_create!(quiz_question_id: nil, quiz_answer_id: 38, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
# Belong to Questions 12
QuizContent.where(id: 56).first_or_create!(quiz_question_id: 12, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 57).first_or_create!(quiz_question_id: nil, quiz_answer_id: 39, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 58).first_or_create!(quiz_question_id: nil, quiz_answer_id: 40, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 59).first_or_create!(quiz_question_id: nil, quiz_answer_id: 41, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 60).first_or_create!(quiz_question_id: nil, quiz_answer_id: 42, text_content: "A",  sorting_order: 0)
# Belong to Questions 13
QuizContent.where(id: 61).first_or_create!(quiz_question_id: 13, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 62).first_or_create!(quiz_question_id: nil, quiz_answer_id: 43, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 63).first_or_create!(quiz_question_id: nil, quiz_answer_id: 44, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 64).first_or_create!(quiz_question_id: nil, quiz_answer_id: 45, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 65).first_or_create!(quiz_question_id: nil, quiz_answer_id: 46, text_content: "A",  sorting_order: 0)
# Belong to Questions 14
QuizContent.where(id: 66).first_or_create!(quiz_question_id: 14, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 67).first_or_create!(quiz_question_id: nil, quiz_answer_id: 47, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 68).first_or_create!(quiz_question_id: nil, quiz_answer_id: 48, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 69).first_or_create!(quiz_question_id: nil, quiz_answer_id: 49, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 70).first_or_create!(quiz_question_id: nil, quiz_answer_id: 50, text_content: "A",  sorting_order: 0)
# Belong to Questions 15
QuizContent.where(id: 71).first_or_create!(quiz_question_id: 15, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: 7)
QuizContent.where(id: 72).first_or_create!(quiz_question_id: nil, quiz_answer_id: 51, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 73).first_or_create!(quiz_question_id: nil, quiz_answer_id: 52, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 74).first_or_create!(quiz_question_id: nil, quiz_answer_id: 53, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 75).first_or_create!(quiz_question_id: nil, quiz_answer_id: 54, text_content: "A",  sorting_order: 0)
# Belong to Questions 16
QuizContent.where(id: 76).first_or_create!(quiz_question_id: 16, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: 7)
QuizContent.where(id: 77).first_or_create!(quiz_question_id: nil, quiz_answer_id: 55, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 78).first_or_create!(quiz_question_id: nil, quiz_answer_id: 56, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 79).first_or_create!(quiz_question_id: nil, quiz_answer_id: 57, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 80).first_or_create!(quiz_question_id: nil, quiz_answer_id: 58, text_content: "A",  sorting_order: 0)
# Belong to Questions 17
QuizContent.where(id: 81).first_or_create!(quiz_question_id: 17, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 82).first_or_create!(quiz_question_id: nil, quiz_answer_id: 59, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 83).first_or_create!(quiz_question_id: nil, quiz_answer_id: 60, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 84).first_or_create!(quiz_question_id: nil, quiz_answer_id: 61, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 85).first_or_create!(quiz_question_id: nil, quiz_answer_id: 62, text_content: "A",  sorting_order: 0)
# Belong to Questions 18
QuizContent.where(id: 86).first_or_create!(quiz_question_id: 18, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 87).first_or_create!(quiz_question_id: nil, quiz_answer_id: 63, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 88).first_or_create!(quiz_question_id: nil, quiz_answer_id: 64, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 89).first_or_create!(quiz_question_id: nil, quiz_answer_id: 65, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 90).first_or_create!(quiz_question_id: nil, quiz_answer_id: 66, text_content: "A",  sorting_order: 0)
# Belong to Questions 19
QuizContent.where(id: 91).first_or_create!(quiz_question_id: 19, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 92).first_or_create!(quiz_question_id: nil, quiz_answer_id: 67, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 93).first_or_create!(quiz_question_id: nil, quiz_answer_id: 68, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 94).first_or_create!(quiz_question_id: nil, quiz_answer_id: 69, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 95).first_or_create!(quiz_question_id: nil, quiz_answer_id: 70, text_content: "A",  sorting_order: 0)
# Belong to Questions 20
QuizContent.where(id: 96).first_or_create!(quiz_question_id: 20, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 97).first_or_create!(quiz_question_id: nil, quiz_answer_id: 71, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 98).first_or_create!(quiz_question_id: nil, quiz_answer_id: 72, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 99).first_or_create!(quiz_question_id: nil, quiz_answer_id: 73, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 100).first_or_create!(quiz_question_id: nil, quiz_answer_id: 74, text_content: "A",  sorting_order: 0)

# Belong to Quiz 3
# Belong to Questions 21
QuizContent.where(id: 101).first_or_create!(quiz_question_id: 21, quiz_answer_id: nil, text_content: "Question 1",  sorting_order: 0)
QuizContent.where(id: 102).first_or_create!(quiz_question_id: nil, quiz_answer_id: 75, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
QuizContent.where(id: 103).first_or_create!(quiz_question_id: nil, quiz_answer_id: 76, text_content: 'Test', sorting_order: 100, image_file_name: "arms_up12.png", image_content_type: "image/png", image_file_size: 38661, image_updated_at: "2015-01-08 17:37:52", quiz_solution_id: nil)
QuizContent.where(id: 104).first_or_create!(quiz_question_id: nil, quiz_answer_id: 77, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
QuizContent.where(id: 105).first_or_create!(quiz_question_id: nil, quiz_answer_id: 78, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
# Belong to Questions 22
QuizContent.where(id: 106).first_or_create!(quiz_question_id: 22, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 107).first_or_create!(quiz_question_id: nil, quiz_answer_id: 79, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 108).first_or_create!(quiz_question_id: nil, quiz_answer_id: 80, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 109).first_or_create!(quiz_question_id: nil, quiz_answer_id: 81, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 110).first_or_create!(quiz_question_id: nil, quiz_answer_id: 82, text_content: "A",  sorting_order: 0)
# Belong to Questions 23
QuizContent.where(id: 111).first_or_create!(quiz_question_id: 23, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 112).first_or_create!(quiz_question_id: nil, quiz_answer_id: 83, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 113).first_or_create!(quiz_question_id: nil, quiz_answer_id: 84, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 114).first_or_create!(quiz_question_id: nil, quiz_answer_id: 85, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 115).first_or_create!(quiz_question_id: nil, quiz_answer_id: 86, text_content: "A",  sorting_order: 0)
# Belong to Questions 24
QuizContent.where(id: 116).first_or_create!(quiz_question_id: 24, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 117).first_or_create!(quiz_question_id: nil, quiz_answer_id: 87, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 118).first_or_create!(quiz_question_id: nil, quiz_answer_id: 88, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 119).first_or_create!(quiz_question_id: nil, quiz_answer_id: 89, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 120).first_or_create!(quiz_question_id: nil, quiz_answer_id: 90, text_content: "A",  sorting_order: 0)
# Belong to Questions 25
QuizContent.where(id: 121).first_or_create!(quiz_question_id: 25, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: 7)
QuizContent.where(id: 122).first_or_create!(quiz_question_id: nil, quiz_answer_id: 91, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 123).first_or_create!(quiz_question_id: nil, quiz_answer_id: 92, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 124).first_or_create!(quiz_question_id: nil, quiz_answer_id: 93, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 125).first_or_create!(quiz_question_id: nil, quiz_answer_id: 94, text_content: "A",  sorting_order: 0)
# Belong to Questions 26
QuizContent.where(id: 126).first_or_create!(quiz_question_id: 26, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: 7)
QuizContent.where(id: 127).first_or_create!(quiz_question_id: nil, quiz_answer_id: 95, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 128).first_or_create!(quiz_question_id: nil, quiz_answer_id: 96, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 129).first_or_create!(quiz_question_id: nil, quiz_answer_id: 97, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 130).first_or_create!(quiz_question_id: nil, quiz_answer_id: 98, text_content: "A",  sorting_order: 0)
# Belong to Questions 27
QuizContent.where(id: 131).first_or_create!(quiz_question_id: 27, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 134).first_or_create!(quiz_question_id: nil, quiz_answer_id: 99, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 135).first_or_create!(quiz_question_id: nil, quiz_answer_id: 100, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 136).first_or_create!(quiz_question_id: nil, quiz_answer_id: 101, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 137).first_or_create!(quiz_question_id: nil, quiz_answer_id: 102, text_content: "A",  sorting_order: 0)
# Belong to Questions 28
QuizContent.where(id: 138).first_or_create!(quiz_question_id: 28, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 139).first_or_create!(quiz_question_id: nil, quiz_answer_id: 103, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 140).first_or_create!(quiz_question_id: nil, quiz_answer_id: 104, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 141).first_or_create!(quiz_question_id: nil, quiz_answer_id: 105, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 142).first_or_create!(quiz_question_id: nil, quiz_answer_id: 106, text_content: "A",  sorting_order: 0)
# Belong to Questions 29
QuizContent.where(id: 143).first_or_create!(quiz_question_id: 29, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 144).first_or_create!(quiz_question_id: nil, quiz_answer_id: 107, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 145).first_or_create!(quiz_question_id: nil, quiz_answer_id: 108, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 146).first_or_create!(quiz_question_id: nil, quiz_answer_id: 109, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 147).first_or_create!(quiz_question_id: nil, quiz_answer_id: 110, text_content: "A",  sorting_order: 0)
# Belong to Questions 30
QuizContent.where(id: 148).first_or_create!(quiz_question_id: 30, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 149).first_or_create!(quiz_question_id: nil, quiz_answer_id: 111, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 150).first_or_create!(quiz_question_id: nil, quiz_answer_id: 112, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 151).first_or_create!(quiz_question_id: nil, quiz_answer_id: 113, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 152).first_or_create!(quiz_question_id: nil, quiz_answer_id: 114, text_content: "A",  sorting_order: 0)



# Belong to Quiz 4
# Belong to Questions 31
QuizContent.where(id: 153).first_or_create!(quiz_question_id: 31, quiz_answer_id: nil, text_content: "Question 1",  sorting_order: 0)
QuizContent.where(id: 154).first_or_create!(quiz_question_id: nil, quiz_answer_id: 115, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
QuizContent.where(id: 155).first_or_create!(quiz_question_id: nil, quiz_answer_id: 116, text_content: 'Test',  sorting_order: 100, image_file_name: "arms_up12.png", image_content_type: "image/png", image_file_size: 38661, image_updated_at: "2015-01-08 17:37:52", quiz_solution_id: nil)
QuizContent.where(id: 156).first_or_create!(quiz_question_id: nil, quiz_answer_id: 117, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
QuizContent.where(id: 157).first_or_create!(quiz_question_id: nil, quiz_answer_id: 118, text_content: "123",  sorting_order: 0, quiz_solution_id: nil)
# Belong to Questions 32
QuizContent.where(id: 158).first_or_create!(quiz_question_id: 32, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 159).first_or_create!(quiz_question_id: nil, quiz_answer_id: 119, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 160).first_or_create!(quiz_question_id: nil, quiz_answer_id: 120, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 161).first_or_create!(quiz_question_id: nil, quiz_answer_id: 121, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 162).first_or_create!(quiz_question_id: nil, quiz_answer_id: 122, text_content: "A",  sorting_order: 0)
# Belong to Questions 33
QuizContent.where(id: 163).first_or_create!(quiz_question_id: 33, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 164).first_or_create!(quiz_question_id: nil, quiz_answer_id: 123, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 165).first_or_create!(quiz_question_id: nil, quiz_answer_id: 124, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 166).first_or_create!(quiz_question_id: nil, quiz_answer_id: 125, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 167).first_or_create!(quiz_question_id: nil, quiz_answer_id: 126, text_content: "A",  sorting_order: 0)
# Belong to Questions 34
QuizContent.where(id: 168).first_or_create!(quiz_question_id: 34, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 169).first_or_create!(quiz_question_id: nil, quiz_answer_id: 127, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 170).first_or_create!(quiz_question_id: nil, quiz_answer_id: 128, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 171).first_or_create!(quiz_question_id: nil, quiz_answer_id: 129, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 172).first_or_create!(quiz_question_id: nil, quiz_answer_id: 130, text_content: "A",  sorting_order: 0)
# Belong to Questions 35
QuizContent.where(id: 173).first_or_create!(quiz_question_id: 35, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: 7)
QuizContent.where(id: 174).first_or_create!(quiz_question_id: nil, quiz_answer_id: 131, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 175).first_or_create!(quiz_question_id: nil, quiz_answer_id: 132, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 176).first_or_create!(quiz_question_id: nil, quiz_answer_id: 133, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 177).first_or_create!(quiz_question_id: nil, quiz_answer_id: 134, text_content: "A",  sorting_order: 0)
# Belong to Questions 36
QuizContent.where(id: 178).first_or_create!(quiz_question_id: 36, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: 7)
QuizContent.where(id: 179).first_or_create!(quiz_question_id: nil, quiz_answer_id: 135, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 180).first_or_create!(quiz_question_id: nil, quiz_answer_id: 136, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 181).first_or_create!(quiz_question_id: nil, quiz_answer_id: 137, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 182).first_or_create!(quiz_question_id: nil, quiz_answer_id: 138, text_content: "A",  sorting_order: 0)
# Belong to Questions 37
QuizContent.where(id: 183).first_or_create!(quiz_question_id: 37, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 184).first_or_create!(quiz_question_id: nil, quiz_answer_id: 139, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 185).first_or_create!(quiz_question_id: nil, quiz_answer_id: 140, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 186).first_or_create!(quiz_question_id: nil, quiz_answer_id: 141, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 187).first_or_create!(quiz_question_id: nil, quiz_answer_id: 142, text_content: "A",  sorting_order: 0)
# Belong to Questions 38
QuizContent.where(id: 188).first_or_create!(quiz_question_id: 38, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 189).first_or_create!(quiz_question_id: nil, quiz_answer_id: 143, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 190).first_or_create!(quiz_question_id: nil, quiz_answer_id: 144, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 191).first_or_create!(quiz_question_id: nil, quiz_answer_id: 145, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 192).first_or_create!(quiz_question_id: nil, quiz_answer_id: 146, text_content: "A",  sorting_order: 0)
# Belong to Questions 39
QuizContent.where(id: 193).first_or_create!(quiz_question_id: 39, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 194).first_or_create!(quiz_question_id: nil, quiz_answer_id: 147, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 195).first_or_create!(quiz_question_id: nil, quiz_answer_id: 148, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 196).first_or_create!(quiz_question_id: nil, quiz_answer_id: 149, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 197).first_or_create!(quiz_question_id: nil, quiz_answer_id: 150, text_content: "A",  sorting_order: 0)
# Belong to Questions 40
QuizContent.where(id: 198).first_or_create!(quiz_question_id: 40, quiz_answer_id: nil, text_content: "The answer is atmosphere",  sorting_order: 1, quiz_solution_id: nil)
QuizContent.where(id: 199).first_or_create!(quiz_question_id: nil, quiz_answer_id: 151, text_content: "ASDF",  sorting_order: 0)
QuizContent.where(id: 200).first_or_create!(quiz_question_id: nil, quiz_answer_id: 152, text_content: "ASD",  sorting_order: 0)
QuizContent.where(id: 201).first_or_create!(quiz_question_id: nil, quiz_answer_id: 153, text_content: "AS",  sorting_order: 0)
QuizContent.where(id: 202).first_or_create!(quiz_question_id: nil, quiz_answer_id: 154, text_content: "A",  sorting_order: 0)





