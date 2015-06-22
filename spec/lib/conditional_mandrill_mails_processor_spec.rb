require 'rails_helper'
require 'mandrill_client'
require 'conditional_mandrill_mails_processor'

describe ConditionalMandrillMailsProcessor do
  let(:student) { FactoryGirl.create(:individual_student_user) }
  let(:subject_area) { FactoryGirl.create(:subject_area) }
  let(:institution) { FactoryGirl.create(:institution, subject_area_id: subject_area.id) }
  let(:qualification) { FactoryGirl.create(:qualification, institution_id: institution.id) }

  let(:exam_level_no_sections) { FactoryGirl.create(:active_exam_level_without_exam_sections,
                       qualification_id: qualification.id) }
  let(:cm_for_level) { FactoryGirl.create(:active_course_module,
                                                    exam_level_id: exam_level_no_sections.id) }
  let(:cmes_for_level) { FactoryGirl.create_list(:cme_quiz, 10,
                                                 course_module_id: cm_for_level.id) }

  let(:exam_level_with_sections) { FactoryGirl.create(:active_exam_level_with_exam_sections,
                       qualification_id: qualification.id) }
  let(:exam_section) { FactoryGirl.create(:active_exam_section,
                       exam_level_id: exam_level_with_sections.id) }
  let(:cm_for_section) { FactoryGirl.create(:active_course_module,
                                            exam_level_id: exam_section.exam_level_id,
                                            exam_section_id: exam_section.id) }
  let(:cmes_for_section) { FactoryGirl.create_list(:cme_quiz, 10,
                                                   course_module_id: cm_for_section.id) }

  context "no eligible student exam tracks" do
    context "track's update date does not match selected calculation start" do
      it "does not send mail if start is yesterday and track was updated day before" do
        se_track = FactoryGirl.create(:student_exam_track,
                                      user_id: student.id,
                                      exam_level_id: exam_level_no_sections.id,
                                      exam_section_id: nil,
                                      course_module_id: cm_for_level.id,
                                      latest_course_module_element_id: cmes_for_level[0].id,
                                      session_guid: "abc123fgh",
                                      percentage_complete: 10)

        1.upto(ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW) do |idx|
          FactoryGirl.create(:course_module_element_user_log,
                             course_module_element_id: cmes_for_level[idx - 1].id,
                             user_id: student.id,
                             session_guid: "abc123fgh",
                             course_module_id: cm_for_level.id,
                             updated_at: idx.days.ago)
        end

        se_track.update_attribute(:updated_at, 2.days.ago)

        ConditionalMandrillMailsProcessor.process_study_streak('yesterday')

        expect(MandrillClient).not_to receive(:new)
      end

      it "does not send mail if start is today and track was updated day before" do
        se_track = FactoryGirl.create(:student_exam_track,
                                      user_id: student.id,
                                      exam_level_id: exam_level_no_sections.id,
                                      exam_section_id: nil,
                                      course_module_id: cm_for_level.id,
                                      latest_course_module_element_id: cmes_for_level[0].id,
                                      session_guid: "abc123fgh",
                                      percentage_complete: 10)

        1.upto(ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW) do |idx|
          FactoryGirl.create(:course_module_element_user_log,
                             course_module_element_id: cmes_for_level[idx - 1].id,
                             user_id: student.id,
                             session_guid: "abc123fgh",
                             course_module_id: cm_for_level.id,
                             updated_at: idx.days.ago)
        end

        se_track.update_attribute(:updated_at, 1.day.ago)

        ConditionalMandrillMailsProcessor.process_study_streak('today')

        expect(MandrillClient).not_to receive(:new)
      end

      it "does not send mail if user id is null" do
        se_track = FactoryGirl.create(:student_exam_track,
                                      user_id: nil,
                                      exam_level_id: exam_level_no_sections.id,
                                      exam_section_id: nil,
                                      course_module_id: cm_for_level.id,
                                      latest_course_module_element_id: cmes_for_level[0].id,
                                      session_guid: "abc123fgh",
                                      percentage_complete: 10)

        1.upto(ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW) do |idx|
          FactoryGirl.create(:course_module_element_user_log,
                             course_module_element_id: cmes_for_level[idx - 1].id,
                             user_id: student.id,
                             session_guid: "abc123fgh",
                             course_module_id: cm_for_level.id,
                             updated_at: idx.days.ago)
        end

        se_track.update_attribute(:updated_at, 1.day.ago)

        ConditionalMandrillMailsProcessor.process_study_streak('yesterday')

        expect(MandrillClient).not_to receive(:new)
      end
    end

    describe "invalid course module element user logs" do
      it "does not send mail if there are not enough course module element user logs for exam level" do
        se_track = FactoryGirl.create(:student_exam_track,
                                      user_id: student.id,
                                      exam_level_id: exam_level_no_sections.id,
                                      exam_section_id: nil,
                                      course_module_id: cm_for_level.id,
                                      latest_course_module_element_id: cmes_for_level[0].id,
                                      session_guid: "abc123fgh",
                                      percentage_complete: 10)
        1.upto(ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW - 1) do |idx|
          FactoryGirl.create(:course_module_element_user_log,
                             course_module_element_id: cmes_for_level[idx - 1].id,
                             user_id: student.id,
                             session_guid: "abc123fgh",
                             course_module_id: cm_for_level.id)
        end

        ConditionalMandrillMailsProcessor.process_study_streak('today')

        expect(MandrillClient).not_to receive(:new)
      end

      it "does not send mail if user has not worked on exam level for defined number of days in a row" do
        se_track = FactoryGirl.create(:student_exam_track,
                                      user_id: student.id,
                                      exam_level_id: exam_level_no_sections.id,
                                      exam_section_id: nil,
                                      course_module_id: cm_for_level.id,
                                      latest_course_module_element_id: cmes_for_level[0].id,
                                      session_guid: "abc123fgh",
                                      percentage_complete: 10)

        # User has accessed 1 day less in a row
        1.upto(ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW) do |idx|
          FactoryGirl.create(:course_module_element_user_log,
                             course_module_element_id: cmes_for_level[idx - 1].id,
                             user_id: student.id,
                             session_guid: "abc123fgh",
                             course_module_id: cm_for_level.id,
                             updated_at: idx < ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW - 1 ? idx.days.ago : 8.days.ago)
        end
        ConditionalMandrillMailsProcessor.process_study_streak('today')
        expect(MandrillClient).not_to receive(:new)

        # there is difference of more than one day
        last_cmeul = CourseModuleElementUserLog.last
        last_cmeul.update_attribute(:updated_at, last_cmeul.updated_at - 2.days)
        ConditionalMandrillMailsProcessor.process_study_streak('today')
        expect(MandrillClient).not_to receive(:new)
      end

      it "does not send mail if there are not enough course module element user logs for exam section" do
        se_track = FactoryGirl.create(:student_exam_track,
                                      user_id: student.id,
                                      exam_level_id: exam_level_with_sections.id,
                                      exam_section_id: exam_section.id,
                                      course_module_id: cm_for_section.id,
                                      latest_course_module_element_id: cmes_for_section[0].id,
                                      session_guid: "abc123fgh",
                                      percentage_complete: 10)
        1.upto(ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW - 1) do |idx|
          FactoryGirl.create(:course_module_element_user_log,
                             course_module_element_id: cmes_for_section[idx - 1].id,
                             user_id: student.id,
                             session_guid: "abc123fgh",
                             course_module_id: cm_for_section.id)
        end

        ConditionalMandrillMailsProcessor.process_study_streak('today')

        expect(MandrillClient).not_to receive(:new)
      end

      it "does not send mail if user has not worked on exam section for defined number of days in a row" do
        se_track = FactoryGirl.create(:student_exam_track,
                                      user_id: student.id,
                                      exam_level_id: exam_level_with_sections.id,
                                      exam_section_id: exam_section.id,
                                      course_module_id: cm_for_section.id,
                                      latest_course_module_element_id: cmes_for_section[0].id,
                                      session_guid: "abc123fgh",
                                      percentage_complete: 10)

        # User has accessed 1 day less in a row
        1.upto(ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW) do |idx|
          FactoryGirl.create(:course_module_element_user_log,
                             course_module_element_id: cmes_for_section[idx - 1].id,
                             user_id: student.id,
                             session_guid: "abc123fgh",
                             course_module_id: cm_for_section.id,
                             updated_at: idx < ConditionalMandrillMailsProcessor::DAYS_IN_A_ROW - 1 ? idx.days.ago : 8.days.ago)
        end
        ConditionalMandrillMailsProcessor.process_study_streak('today')
        expect(MandrillClient).not_to receive(:new)

        # there is difference of more than one day
        last_cmeul = CourseModuleElementUserLog.last
        last_cmeul.update_attribute(:updated_at, last_cmeul.updated_at - 2.days)
        ConditionalMandrillMailsProcessor.process_study_streak('today')
        expect(MandrillClient).not_to receive(:new)
      end
    end
  end
end
