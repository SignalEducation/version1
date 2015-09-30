class Contact < MailForm::Base

  # validation
  attribute :name,      validate: true, length: {maximum: 255}
  attribute :title,      validate: true, length: {maximum: 255}
  attribute :email,      validate: true, length: {maximum: 255}
  attribute :company,      validate: true, length: {maximum: 255}
  attribute :phone_number,      validate: true, length: {maximum: 255}
  attribute :website,      validate: true, length: {maximum: 255}
  attribute :message,      validate: true, length: {maximum: 255}

  def headers
    {
        subject: 'Corporate Account Enquiry',
        to: 'james@learnsignal.com',
        from: "#{email}"
    }
  end

end