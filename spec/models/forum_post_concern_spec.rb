require 'rails_helper'

describe ForumPostConcern do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ForumPostConcern.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ForumPostConcern.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:forum_post) }
  it { should belong_to(:user) }

  # validation
  it { should validate_presence_of(:forum_post_id) }
  it { should validate_numericality_of(:forum_post_id) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:reason) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ForumPostConcern).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
