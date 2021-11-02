# Change this to your host. See the readme at https://github.com/lassebunk/dynamic_sitemaps
# for examples of multiple hosts and folders.
host 'app.learnsignal.com'

sitemap :site do

  #Landing Pages
  url root_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0

  HomePage.where(home: false, seo_no_index: false).each do |home_page|
    url "https://#{host}/#{home_page.public_url}", last_mod: home_page.updated_at, change_freq: 'monthly', priority: 1.0
  end

  #Library

  groups = Group.all_active.all_in_order
  if groups.count > 1
    url library_url, last_mod: groups.last.updated_at, change_freq: 'monthly', priority: 1.0
  end

  groups.each do |group|
    url library_group_url(group_name_url: group.name_url), last_mod: group.updated_at, change_freq: 'monthly', priority: 1.0
    group.active_children.all_in_order.each do |course|
      url library_course_url(group_name_url: group.name_url, course_name_url: course.name_url), last_mod: course.updated_at, change_freq: 'monthly', priority: 1.0
    end
  end

  products = Product.all_active
  if products.count > 0
    url prep_products_url, last_mod: products.last.created_at, change_freq: 'monthly', priority: 1.0
  end

  #Sign In, Forgot Password
  url new_student_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url sign_in_or_register_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url sign_in_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url forgot_password_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0


  #Tutor Profile pages
  User.all_tutors.with_course_tutors.where.not(profile_image_file_name: nil).each do |tutor|
    url profile_url(tutor.name_url, locale: 'en'), last_mod: tutor.updated_at, change_freq: 'monthly', priority: 1.0
  end

  #Footer pages + other static pages
  url tutors_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url contact_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url acca_info_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url privacy_policy_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url terms_and_conditions_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0
  url public_faqs_url, last_mod: Time.now, change_freq: 'monthly', priority: 1.0

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
