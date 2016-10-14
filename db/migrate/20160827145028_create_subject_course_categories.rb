class CreateSubjectCourseCategories < ActiveRecord::Migration
  def up
    create_table :subject_course_categories do |t|
      t.string :name, index: true
      t.string :payment_type
      t.boolean :active, default: false
      t.string :subdomain, index: true

      t.timestamps null: false
    end

    unless Rails.env.test?
      SubjectCourseCategory.new(name: "Subscription Category", payment_type: "Subscription", active: true, subdomian: nil).tap do |cat|
        cat.save
      end
      SubjectCourseCategory.new(name: "Product Category", payment_type: 'Product', active: true, subdomian: nil).tap do |cat|
        cat.save
      end
      SubjectCourseCategory.new(name: "Corporate Category", payment_type: 'Corporate', active: true, subdomian: nil).tap do |cat|
        cat.save
      end
    end
  end

  def down
    drop_table :subject_course_categories
  end

end
