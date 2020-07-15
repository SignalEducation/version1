# frozen_string_literal: true

class MessagesController < ApplicationController
  def unsubscribe
    @message = Message.get_and_unsubscribe(params[:message_guid])
  end
end
