# frozen_string_literal: true

json.partial! 'api/v1/users/user', locals: { user: @user, remain_days: @user.verify_remain_days}
