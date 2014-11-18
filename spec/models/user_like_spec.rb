# == Schema Information
#
# Table name: user_likes
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  likeable_type :string(255)
#  likeable_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

describe UserLike do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  UserLike.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(UserLike.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:likeable) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:likeable_type) }

  it { should validate_presence_of(:likeable_id) }
  it { should validate_numericality_of(:likeable_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserLike).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
