class <%= class_name -%> < ActiveRecord::Base

  # attr-accessible
  attr_accessible <%= attributes.map { |x| ':' + x.name}.join(', ') %>

  # Constants

  # relationships
  <%- attributes.each do |attribute| -%>
  <%- if attribute.name[-3..-1] == '_id' -%>
  belongs_to :<%= attribute.name.gsub('_id','') %>
  <%- end -%>
  <%- end -%>

  # validation
  <%- attributes.each do |attribute| -%>
  <%- if attribute.name[-3..-1] == '_id' -%>
  validates :<%= attribute.name %>, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  <%- elsif attribute.type.to_s != 'boolean' -%>
  validates :<%= attribute.name %>, presence: true
  <%- end -%>
  <%- end -%>

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:<%= attributes.map(&:name).includes?('sorting_order') ? 'sorting_order, ' : '' -%><%= attributes.first.name %>) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
