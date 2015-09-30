class ContactsController < ApplicationController

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
      flash.now[:success] = 'Thank you for your enquiry. We will contact you soon!'
    else
      flash.now[:error] = 'Could not submit request. Please try again!'
      render root_url
    end
  end

end