# frozen_string_literal: true

json.array! @users_log do |user_log|
  json.partial! 'user_log', locals: { user_log: user_log }
end
