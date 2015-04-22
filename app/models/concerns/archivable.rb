# activate this module in any AR model using
# include Archivable
#
# Add the following into the model:
# def destroyable_children
#   the_list = []
#   self.related_things.to_a + self.other_things.to_a
#   the_list << self.has_one_thing if self.has_one_thing
#   the_list
# end
#
# Also, you should ensure that the model has a datetime called "destroyed_at"

module Archivable
  extend ActiveSupport::Concern

  included do
    scope :all_destroyed, -> { where.not(destroyed_at: nil) }
  end

  def destroy
    # Assumes the model has a "destroyed_at" attribute.
    self.update_attributes(destroyed_at: Proc.new{Time.now}.call)
    if self.try(:destroyable_children)
      self.destroyable_children.map {|x| x.destroy}
    end
  end

  def un_delete
    self.update_attributes(destroyed_at: nil)
  end

end
