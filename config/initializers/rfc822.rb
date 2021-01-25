# frozen_string_literal: true

module RFC822
  QTEXT = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
  DTEXT = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
  ATOM = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
  QUOTED_PAIR = '\\x5c[\\x00-\\x7f]'
  DOMAIN_LITERAL = "\\x5b(?:#{DTEXT}|#{QUOTED_PAIR})*\\x5d"
  QUOTED_STRING = "\\x22(?:#{QTEXT}|#{QUOTED_PAIR})*\\x22"
  DOMAIN_REF = ATOM
  SUB_DOMAIN = "(?:#{DOMAIN_REF}|#{DOMAIN_LITERAL})"
  WORD = "(?:#{ATOM}|#{QUOTED_STRING})"
  DOMAIN = "#{SUB_DOMAIN}(?:\\x2e#{SUB_DOMAIN})*"
  LOCAL_PART = "#{WORD}(?:\\x2e#{WORD})*"
  ADDR_SPEC = "#{LOCAL_PART}\\x40#{DOMAIN}"

  EMAIL_REGEXP_WHOLE = Regexp.new("\\A#{ADDR_SPEC}\\z", nil, 'n')
  EMAIL_REGEXP_PART = Regexp.new(ADDR_SPEC.to_s, nil, 'n')
end
