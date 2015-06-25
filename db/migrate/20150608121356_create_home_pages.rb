class CreateHomePages < ActiveRecord::Migration
  def up
    create_table :home_pages do |t|
      t.string :seo_title
      t.string :seo_description
      t.integer :subscription_plan_category_id, index: true
      t.string :public_url, index: true

      t.timestamps null: false
    end

    unless Rails.env.test?
      HomePage.create(public_url: '/', seo_title: 'Learn Signal', seo_description: 'Learn Signal').tap do |home|
        home.save
        end
      HomePage.create(public_url: '/acca', seo_title: 'Learn Signal', seo_description: 'Learn Signal').tap do |acca|
        acca.save
      end
      HomePage.create(public_url: '/cfa', seo_title: 'Learn Signal', seo_description: 'Learn Signal').tap do |cfa|
        cfa.save
      end

    end

  end

  def down
    drop_table :home_pages
  end
end
