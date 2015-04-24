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
    scope :all_live, -> { where(destroyed_at: nil) }
    default_scope{all_live}
  end

  def destroy
    Rails.logger.debug 'DEBUG: Archivable#destroy: activated'
    # Assumes the model has a "destroyed_at" attribute.
    self.destroyed_at = Proc.new { Time.now }.call
    self.active = false if self.respond_to?(:active)
    self.destroyable_children.map { |x| x.destroy } if self.respond_to?(:destroyable_children)
    self.save
  end

  def un_delete
    self.update_attributes(destroyed_at: nil)
  end

end
