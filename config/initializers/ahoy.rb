class Ahoy::Store < Ahoy::DatabaseStore
  protected
  def visit_model
    ::Visit
  end
end
