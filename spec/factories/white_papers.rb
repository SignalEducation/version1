# == Schema Information
#
# Table name: white_papers
#
#  id                :integer          not null, primary key
#  title             :string
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  sorting_order     :integer
#

FactoryGirl.define do
  factory :white_paper do
    title "MyString"
description "MyText"
  end

end
