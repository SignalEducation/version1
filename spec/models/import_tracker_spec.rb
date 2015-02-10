# == Schema Information
#
# Table name: import_trackers
#
#  id             :integer          not null, primary key
#  old_model_name :string(255)
#  old_model_id   :integer
#  new_model_name :string(255)
#  new_model_id   :integer
#  imported_at    :datetime
#  original_data  :text
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

describe ImportTracker do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ImportTracker.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ImportTracker.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:old_model) }
  it { should belong_to(:new_model) }

  # validation
  it { should validate_presence_of(:old_model_name) }

  it { should validate_presence_of(:old_model_id) }
  it { should validate_numericality_of(:old_model_id) }

  it { should validate_presence_of(:new_model_name) }

  it { should validate_presence_of(:new_model_id) }
  it { should validate_numericality_of(:new_model_id) }

  it { should validate_presence_of(:imported_at) }

  it { should validate_presence_of(:original_data) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ImportTracker).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
