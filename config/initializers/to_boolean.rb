module ToBoolean
  def to_bool
    ActiveRecord::Type::Boolean.new.cast(self)
  end
end

class String; include ToBoolean; end
