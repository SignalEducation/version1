# activate this module in any AR model using
# include Archivable
#
# Add the following into the model:
# def destroyable_children
#   self.related_things.to_a + self.other_things.to_a
# end
#
# Also, you should ensure that the model has a datetime called "destroyed_at"

module Archivable

  def destroy
    # Assumes the model has a "destroyed_at" attribute.
    self.update_attributes(destroyed_at: Proc.new{Time.now}.call)
    if self.try(:destroyable_children)
      self.destroyable_children.map {|x| x.destroy}
    end
  end

end
