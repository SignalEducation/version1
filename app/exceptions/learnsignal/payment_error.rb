class Learnsignal::PaymentError < StandardError
  attr_reader :message

  def initialize(message)
    # Call the parent's constructor to set the message
    super(message)

    @message = message
  end
end