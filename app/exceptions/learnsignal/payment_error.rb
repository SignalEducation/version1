class Learnsignal::PaymentError < StandardError
  attr_reader :message

  def initialize(message)
    super(message)

    @message = message
  end
end