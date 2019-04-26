namespace :sitemap do
  desc 'Sym-linking the two sitemap files'
  task :symlink do
    puts 'Running sym link rake command ...'
    system("cp #{Rails.root}/public/sitemaps/sitemap.xml #{Rails.root}/public/sitemap.xml")
    puts 'DONE'
  end
end
