# == Schema Information
#
# Table name: white_paper_requests
#
#  id             :integer          not null, primary key
#  name           :string
#  email          :string
#  number         :string
#  web_url        :string
#  company_name   :string
#  white_paper_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

describe WhitePaperRequest do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  WhitePaperRequest.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(WhitePaperRequest.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:white_paper) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:email) }

  it { should validate_presence_of(:number) }

  it { should validate_presence_of(:web_url) }

  it { should validate_presence_of(:company_name) }

  it { should validate_presence_of(:white_paper_id) }
  it { should validate_numericality_of(:white_paper_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(WhitePaperRequest).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
