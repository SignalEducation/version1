# == Schema Information
#
# Table name: video_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  question                 :text
#  answer                   :text
#  notes                    :text
#  destroyed_at             :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  transcript               :text
#

require 'rails_helper'

describe VideoResource do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  VideoResource.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to :course_module_element }

  # validation
  it { should validate_presence_of(:course_module_element_id) }

  it { should_not validate_presence_of(:question) }

  it { should_not validate_presence_of(:answer) }

  it { should_not validate_presence_of(:notes) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(VideoResource).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
