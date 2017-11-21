# See https://github.com/mperham/sidekiq/wiki/Monitoring

class AdminConstraint
  def matches?(request)
    return false unless request.cookies['user_credentials'].present?
    user = User.find_by_persistence_token(request.cookies['user_credentials'].split(':')[0])
    user && (user.developer_access? || user.user_management_access?|| user.system_requirements_access?)
  end
end
