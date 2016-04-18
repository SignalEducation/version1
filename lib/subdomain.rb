class Subdomain
  def self.matches?(request)
    case request.subdomain
      when 'www', '', nil, 'learnsignal', 'staging'
        false
      else
        true
    end
  end
end
