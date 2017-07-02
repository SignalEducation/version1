# Change this to your host. See the readme at https://github.com/lassebunk/dynamic_sitemaps
# for examples of multiple hosts and folders.
host 'learnsignal.com'

sitemap :site do

  #Landing Pages
  url root_url, last_mod: Time.now, change_freq: 'weekly', priority: 1.0
  business_page = HomePage.where(public_url: '/business').first
  acca_page = HomePage.where(public_url: '/acca').first
  cfa_page = HomePage.where(public_url: '/cfa').first
  wso_page = HomePage.where(public_url: '/wso').first
  url business_url, last_mod: business_page.updated_at, change_freq: 'weekly', priority: 1.0
  url acca_url, last_mod: acca_page.updated_at, change_freq: 'weekly', priority: 1.0
  url cfa_url, last_mod: cfa_page.updated_at, change_freq: 'weekly', priority: 1.0
  url wso_url, last_mod: wso_page.updated_at, change_freq: 'weekly', priority: 1.0

  #Pricing page
  last_updated_plan = SubscriptionPlan.generally_available.for_students.all_active.all_in_update_order.last
  url pricing_url, last_mod: last_updated_plan.updated_at, change_freq: 'monthly', priority: 1.0
  #Tutor Profile pages
  User.all_tutors.where.not(profile_image_file_name: nil).each do |tutor|
    url profile_url(tutor, locale: 'en'), last_mod: tutor.updated_at, change_freq: 'weekly', priority: 1.0
  end
  #Footer pages + other static pages
  url why_learn_signal_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url careers_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url tutors_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url contact_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url terms_and_conditions_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0

  #Library
  def library_special_link(the_thing)
    if the_thing.class == Group
      the_thing = the_thing
      library_group_url(
          the_thing.name_url,
          locale: 'en'
      )
    elsif the_thing.class == SubjectCourse
      the_thing = the_thing
      library_course_url(
          the_thing.name_url,
          locale: 'en'
      )
    else
      library_url
    end
  end
  url library_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  Group.all_active.each do |group|
    url library_special_link(group), last_mod: group.updated_at, change_freq: 'weekly', priority: 1.0
  end
  SubjectCourse.all_active.all_not_restricted.each do |course|
    url library_special_link(course), last_mod: course.updated_at, change_freq: 'weekly', priority: 1.0
  end
  #Sign In, Forgot Password
  url sign_in_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url forgot_password_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0

end

# You can have multiple sitemaps like the above – just make sure their names are different.

# Automatically link to all pages using the routes specified
# using "resources :pages" in config/routes.rb. This will also
# automatically set <lastmod> to the date and time in page.updated_at:
#
#   sitemap_for Page.scoped

# For products with special sitemap name and priority, and link to comments:
#
#   sitemap_for Product.published, name: :published_products do |product|
#     url product, last_mod: product.updated_at, priority: (product.featured? ? 1.0 : 0.7)
#     url product_comments_url(product)
#   end

# If you want to generate multiple sitemaps in different folders (for example if you have
# more than one domain, you can specify a folder before the sitemap definitions:
# 
#   Site.all.each do |site|
#     folder "sitemaps/#{site.domain}"
#     host site.domain
#     
#     sitemap :site do
#       url root_url
#     end
# 
#     sitemap_for site.products.scoped
#   end

# Ping search engines after sitemap generation:
#
ping_with "http://#{host}/sitemap.xml"