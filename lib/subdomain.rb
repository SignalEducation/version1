class Subdomain
  def self.matches?(request)
    case request.subdomain
      when 'www', '', nil, 'learnsignal', 'staging', 'acca', 'cfa', 'forum', 'jobs', 'course'
        false
      else
        true
    end
  end
end
