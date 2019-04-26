# implement this with the following line of code
# include LearnSignalModelExtras

module LearnSignalModelExtras
  extend ActiveSupport::Concern

  included do
    before_destroy :check_dependencies
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def sanitize_name_url
    # call like this:
    # before_save :sanitize_name_url
    self.name_url = name_url_sanitizer(self.name_url)
  end

  def name_url_sanitizer(the_name_url)
    the_name_url.to_s.gsub(' ', '-').gsub('/', '-').gsub('.', '-').gsub('_', '-').gsub('&', '-').gsub('?', '-').gsub('=', '-').gsub(':', '-').gsub(';', '-').gsub(',','').gsub('[','').gsub(']','').downcase
  end

  def set_sorting_order
    # call like this:
    # before_create :set_sorting_order
    self.sorting_order = self.parent.try(:children).try(:maximum, :sorting_order).to_i + 1
  end

  def squish_fields(*fields_as_symbols)
    # call like this:
    # before_validation { squish_fields(:name, :iso_code, :continent) }
    fields_as_symbols.each do |col_name|
      self[col_name.to_sym] = self[col_name.to_sym].squish if self[col_name.to_sym].respond_to?('squish')
    end
    true
  end

  def update_sitemap
    if Rails.env.production?
      system("RAILS_ENV=#{Rails.env} bundle exec rake sitemap:generate")
      system("RAILS_ENV=#{Rails.env} bundle exec rake sitemap:symlink")
    end
  end

end
