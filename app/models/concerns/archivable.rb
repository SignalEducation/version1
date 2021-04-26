# frozen_string_literal: true

# Important, you probably should not use this concern,
# a default scope could be a nightmare to work.
# Read this article: https://andycroll.com/ruby/dont-use-default-scope/

# activate this module in any AR model using
# include Archivable
#
# Add the following into the model:
# def destroyable_children
#   the_list = []
#   the_list += self.related_things.to_a + self.other_things.to_a
#   the_list << self.has_one_thing if self.has_one_thing
#   the_list
# end
#
# Also, you should ensure that the model has a datetime called "destroyed_at"

module Archivable
  extend ActiveSupport::Concern

  included do
    scope :all_destroyed, -> { unscoped.where.not(destroyed_at: nil) }
    scope :all_not_destroyed, -> { where(destroyed_at: nil) }
    default_scope { all_not_destroyed }
  end

  def destroy
    Rails.logger.debug 'DEBUG: Archivable#destroy: activated'
    # Assumes the model has a "destroyed_at" attribute.
    time              = Time.now.to_i
    self.destroyed_at = proc { Time.zone.now }.call
    self.active       = false                           if respond_to?(:active)
    self.live         = false                           if respond_to?(:live)
    self.name         = "#{name}-destroyed-#{time}"     if respond_to?(:name)
    self.name_url     = "#{name_url}-destroyed-#{time}" if respond_to?(:name_url)
    destroyable_children.map(&:destroy)                 if respond_to?(:destroyable_children)
    save
  end

  def un_delete
    update_attributes(destroyed_at: nil)
  end
end
