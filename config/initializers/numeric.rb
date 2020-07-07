# frozen_string_literal: true

class Numeric
  def percent_of(num)
    self / num.to_f * 100.0
  end
end
