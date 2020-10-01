class AddHubspotPropertyToExamBody < ActiveRecord::Migration[5.2]
  class ExamBody < ActiveRecord::Base
  end

  def change
    add_column :exam_bodies, :hubspot_property, :string

    # update the table
    ExamBody.all.each { |e| e.update(hubspot_property: "#{e.name}_status".parameterize(separator: '_')) }
  end
end
