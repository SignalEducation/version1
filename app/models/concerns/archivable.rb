module Archivable

  def destroy
    # Assumes the model has a "destroyed_at" attribute.
    self.update_attributes(destroyed_at: Proc.new{Time.now}.call)
  end

end