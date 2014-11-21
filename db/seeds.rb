# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
unless Rails.env.test? # don't want this stuff to run in the test DB

  puts '*' * 100
  puts 'Starting the db/seed process'
  puts
  print 'User Groups: '

  UserGroup.where(id: 1).first_or_create!(
          name: 'Individual students', description: 'Self-funded students',
          individual_student: true, tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: true,
          subscription_required_to_see_content: true, forum_manager: false
  ); print '.'

  UserGroup.where(id: 2).first_or_create!(
          name: 'Corporate Student',
          description: 'Student, funded by a corporate customer',
          individual_student: false, corporate_student: true,
          tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: false
  ); print '.'

  UserGroup.where(id: 3).first_or_create!(
          name: 'Corporate customers',
          description: 'Administrative users on behalf of a corporate customer',
          individual_student: false, tutor: false, content_manager: false,
          blogger: false, corporate_customer: true, site_admin: false,
          subscription_required_at_sign_up: true,
          subscription_required_to_see_content: false, forum_manager: false
  ); print '.'

  UserGroup.where(id: 4).first_or_create!(
          name: 'Tutor', description: 'Can create course content',
          individual_student: true, tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up:true,
          subscription_required_to_see_content: true, forum_manager: true
  ); print '.'

  UserGroup.where(id: 5).first_or_create!(
          name: 'Blogger', description: 'Can create blog content',
          individual_student: false, tutor: false, content_manager: false,
          blogger: true, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up:false,
          subscription_required_to_see_content: false, forum_manager: false
  ); print '.'

  UserGroup.where(id: 6).first_or_create!(
          name: 'Forum manager', description: 'Can manage content on the forum',
          individual_student: false, tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: true
  ); print '.'

  UserGroup.where(id: 7).first_or_create!(
          name: 'Content manager',
          description: 'Can manage forum, blog and static pages',
          individual_student: false, tutor: false,
          content_manager: true,
          blogger: true, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: true
  ); print '.'

  UserGroup.where(id: 8).first_or_create!(
          name: 'Admin', description: 'Can do everything', individual_student: false,
          tutor: false, content_manager: true,
          blogger: true, corporate_customer: false, site_admin: true,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: true
  ); print '.'

  puts ' DONE'
  print 'Subject Areas: '
  unless Rails.env.test?
    SubjectArea.where(id: 1).first_or_create!(name: 'Finance', name_url: 'finance',
                        sorting_order: 100, active: true); print '.'
  end

  puts ' DONE'
  print 'Users: '

  unless Rails.env.production?
    generic_default_values = {
            password: '123123123', password_confirmation: '123123123',
            country_id: 1,
            operational_email_frequency: 'daily',
            study_plan_notifications_email_frequency: 'daily',
            falling_behind_email_alert_frequency: 'daily',
            marketing_email_frequency: 'daily',
            blog_notification_email_frequency: 'daily',
            forum_notification_email_frequency: 'daily'
    }
    User.where(id: 1).first_or_create!(generic_default_values.merge({
            email: 'individual.student@example.com',
            first_name: 'Individual',
            last_name: 'Student',
            user_group_id: 1
    })); print '.'

    User.where(id: 2).first_or_create!(generic_default_values.merge({
            email: 'corporate.student@example.com',
            first_name: 'Corporate',
            last_name: 'Student',
            user_group_id: 2, corporate_customer_id: 1
    })); print '.'

    User.where(id: 3).first_or_create!(generic_default_values.merge({
            email: 'corporate.customer@example.com',
            first_name: 'Corporate',
            last_name: 'CustomerUser',
            user_group_id: 3, corporate_customer_id: 1
    })); print '.'

    User.where(id: 4).first_or_create!(generic_default_values.merge({
            email: 'tutor@example.com',
            first_name: 'Doctor',
            last_name: 'Tutor',
            user_group_id: 4
    })); print '.'

    User.where(id: 5).first_or_create!(generic_default_values.merge({
            email: 'blogger@example.com',
            first_name: 'Blogger',
            last_name: 'Writer',
            user_group_id: 5
    })); print '.'

    User.where(id: 6).first_or_create!(generic_default_values.merge({
            email: 'forum.manager@example.com',
            first_name: 'Forum',
            last_name: 'Manager',
            user_group_id: 6
    })); print '.'

    User.where(id: 7).first_or_create!(generic_default_values.merge({
            email: 'content.manager@example.com',
            first_name: 'Content',
            last_name: 'Manager',
            user_group_id: 7
    })); print '.'

    User.where(id: 8).first_or_create!(generic_default_values.merge({
            email: 'site.admin@example.com',
            first_name: 'Site',
            last_name: 'Admin',
            user_group_id: 8
    })); print '.'

    User.where(id: (1..8).to_a).update_all(active: true, account_activated_at: Time.now, account_activation_code: nil)
  end

  puts ' DONE'
  print 'Currencies: '

  Currency.where(id: 1).first_or_create(iso_code: 'EUR', name: 'Euro',
                                        leading_symbol: '€', trailing_symbol: 'c',
                                        active: true, sorting_order: 100); print '.'
  Currency.where(id: 2).first_or_create(iso_code: 'GBP', name: 'Pounds Sterling',
                                        leading_symbol: '£', trailing_symbol: 'p',
                                        active: true, sorting_order: 200); print '.'
  Currency.where(id: 3).first_or_create(iso_code: 'USD', name: 'US Dollar',
                                        leading_symbol: '$', trailing_symbol: 'c',
                                        active: true, sorting_order: 300); print '.'
  Currency.where(id: 4).first_or_create(iso_code: 'CAD', name: 'Canadian Dollar',
                                        leading_symbol: '$', trailing_symbol: 'c',
                                        active: false, sorting_order: 400); print '.'
  Currency.where(id: 5).first_or_create(iso_code: 'HKD', name: 'Hong Kong Dollar',
                                        leading_symbol: '$', trailing_symbol: 'c',
                                        active: false, sorting_order: 500); print '.'
  Currency.where(id: 6).first_or_create(iso_code: 'SGD', name: 'Singapore Dollar',
                                        leading_symbol: '$', trailing_symbol: 'c',
                                        active: false, sorting_order: 600); print '.'

  puts ' DONE'
  print 'Countries: '
  countries = [
      {iso_code: 'AD', name: 'Andorra', country_tld: '.ad'},
      {iso_code: 'AE', name: 'United Arab Emirates', country_tld: '.ae'},
      {iso_code: 'AF', name: 'Afghanistan', country_tld: '.af'},
      {iso_code: 'AG', name: 'Antigua and Barbuda', country_tld: '.ag'},
      {iso_code: 'AI', name: 'Anguilla', country_tld: '.ai'},
      {iso_code: 'AL', name: 'Albania', country_tld: '.al'},
      {iso_code: 'AM', name: 'Armenia', country_tld: '.am'},
      {iso_code: 'AO', name: 'Angola', country_tld: '.ao'},
      {iso_code: 'AQ', name: 'Antarctica', country_tld: '.aq'},
      {iso_code: 'AR', name: 'Argentina', country_tld: '.ar'},
      {iso_code: 'AS', name: 'Samoa', country_tld: '.as'},
      {iso_code: 'WS', name: 'Western Samoa', country_tld: '.ws'},
      {iso_code: 'AT', name: 'Austria', country_tld: '.at', in_the_eu: true},
      {iso_code: 'AU', name: 'Australia', country_tld: '.au'},
      {iso_code: 'AW', name: 'Aruba', country_tld: '.aw'},
      {iso_code: 'AX', name: 'Aland Islands', country_tld: '.ax'},
      {iso_code: 'AZ', name: 'Azerbaijan', country_tld: '.az'},
      {iso_code: 'BA', name: 'Bosnia and Herzegovina', country_tld: '.ba'},
      {iso_code: 'BB', name: 'Barbados', country_tld: '.bb'},
      {iso_code: 'BD', name: 'Bangladesh', country_tld: '.bd'},
      {iso_code: 'BE', name: 'Belgium', country_tld: '.be', in_the_eu: true},
      {iso_code: 'BF', name: 'Burkina Faso', country_tld: '.bf'},
      {iso_code: 'BG', name: 'Bulgaria', country_tld: '.bg', in_the_eu: true},
      {iso_code: 'BH', name: 'Bahrain', country_tld: '.bh'},
      {iso_code: 'BI', name: 'Burundi', country_tld: '.bi'},
      {iso_code: 'BJ', name: 'Benin', country_tld: '.bj'},
      {iso_code: 'BL', name: 'Saint Barthelemy', country_tld: '.bl'},
      {iso_code: 'BM', name: 'Bermuda', country_tld: '.bm'},
      {iso_code: 'BN', name: 'Brunei', country_tld: '.bn'},
      {iso_code: 'BO', name: 'Bolivia', country_tld: '.bo'},
      {iso_code: 'BQ', name: 'Bonaire, Sint Eustatius and Saba', country_tld: '.bq'},
      {iso_code: 'BR', name: 'Brazil', country_tld: '.br'},
      {iso_code: 'BS', name: 'Bahamas', country_tld: '.bs'},
      {iso_code: 'BT', name: 'Bhutan', country_tld: '.bt'},
      {iso_code: 'BV', name: 'Bouvet Island', country_tld: '.bv'},
      {iso_code: 'BW', name: 'Botswana', country_tld: '.bw'},
      {iso_code: 'BY', name: 'Belarus', country_tld: '.by'},
      {iso_code: 'BZ', name: 'Belize', country_tld: '.bz'},
      {iso_code: 'CA', name: 'Canada', country_tld: '.ca'},
      {iso_code: 'CC', name: 'Cocos (Keeling) Islands', country_tld: '.cc'},
      {iso_code: 'CD', name: 'Democratic Republic of Congo', country_tld: '.cd'},
      {iso_code: 'CF', name: 'Central African Republic', country_tld: '.cf'},
      {iso_code: 'CG', name: 'Republic of Congo', country_tld: '.cg'},
      {iso_code: 'CH', name: 'Switzerland', country_tld: '.ch'},
      {iso_code: 'CI', name: "Cote d'Ivoire", country_tld: '.ci'},
      {iso_code: 'CK', name: 'Cook Islands', country_tld: '.ck'},
      {iso_code: 'CL', name: 'Chile', country_tld: '.cl'},
      {iso_code: 'CM', name: 'Cameroon', country_tld: '.cm'},
      {iso_code: 'CN', name: 'Republic of China', country_tld: '.cn'},
      {iso_code: 'CO', name: 'Colombia', country_tld: '.co'},
      {iso_code: 'CR', name: 'Costa Rica', country_tld: '.cr'},
      {iso_code: 'CU', name: 'Cuba', country_tld: '.cu'},
      {iso_code: 'CV', name: 'Cape Verde', country_tld: '.cv'},
      {iso_code: 'CW', name: 'Curacao', country_tld: '.cw'},
      {iso_code: 'CX', name: 'Christmas Island', country_tld: '.cx'},
      {iso_code: 'CY', name: 'Cyprus', country_tld: '.cy', in_the_eu: true},
      {iso_code: 'CZ', name: 'Czech Republic', country_tld: '.cz', in_the_eu: true},
      {iso_code: 'DE', name: 'Germany', country_tld: '.de', in_the_eu: true},
      {iso_code: 'DJ', name: 'Djibouti', country_tld: '.dj'},
      {iso_code: 'DK', name: 'Denmark', country_tld: '.dk', in_the_eu: true},
      {iso_code: 'DM', name: 'Dominica', country_tld: '.dm'},
      {iso_code: 'DO', name: 'Dominican Republic', country_tld: '.do'},
      {iso_code: 'DZ', name: 'Algeria', country_tld: '.dz'},
      {iso_code: 'EC', name: 'Ecuador', country_tld: '.ec'},
      {iso_code: 'EE', name: 'Estonia', country_tld: '.ee', in_the_eu: true},
      {iso_code: 'EG', name: 'Egypt', country_tld: '.eg'},
      {iso_code: 'EH', name: 'Western Sahara', country_tld: '.eh'},
      {iso_code: 'ER', name: 'Eritrea', country_tld: '.er'},
      {iso_code: 'ES', name: 'Spain', country_tld: '.es', in_the_eu: true},
      {iso_code: 'ET', name: 'Ethiopia', country_tld: '.et'},
      {iso_code: 'FI', name: 'Finland', country_tld: '.fi', in_the_eu: true},
      {iso_code: 'FJ', name: 'Fiji', country_tld: '.fj'},
      {iso_code: 'FK', name: 'Falkland Islands', country_tld: '.fk'},
      {iso_code: 'FM', name: 'Micronesia', country_tld: '.fm'},
      {iso_code: 'FO', name: 'Faroe Islands', country_tld: '.fo'},
      {iso_code: 'FR', name: 'France', country_tld: '.fr', in_the_eu: true},
      {iso_code: 'GA', name: 'Gabon', country_tld: '.ga'},
      {iso_code: 'GB', name: 'United Kingdom', country_tld: '.uk', in_the_eu: true},
      {iso_code: 'GD', name: 'Grenada', country_tld: '.gd'},
      {iso_code: 'GE', name: 'Georgia', country_tld: '.ge'},
      {iso_code: 'GF', name: 'French Guiana', country_tld: '.gf'},
      {iso_code: 'GG', name: 'Guernsey', country_tld: '.gg'},
      {iso_code: 'GG', name: 'Alderney', country_tld: '.gg'},
      {iso_code: 'GG', name: 'Sark', country_tld: '.gg'},
      {iso_code: 'GH', name: 'Ghana', country_tld: '.gh'},
      {iso_code: 'GI', name: 'Gibraltar', country_tld: '.gi'},
      {iso_code: 'GL', name: 'Greenland', country_tld: '.gl'},
      {iso_code: 'GM', name: 'Gambia', country_tld: '.gm'},
      {iso_code: 'GN', name: 'Guinea', country_tld: '.gn'},
      {iso_code: 'GP', name: 'Guadeloupe', country_tld: '.gp'},
      {iso_code: 'GQ', name: 'Equatorial Guinea', country_tld: '.gq'},
      {iso_code: 'GR', name: 'Greece', country_tld: '.gr', in_the_eu: true},
      {iso_code: 'GS', name: 'South Georgia and the South Sandwich Islands', country_tld: '.gs'},
      {iso_code: 'GT', name: 'Guatemala', country_tld: '.gt'},
      {iso_code: 'GU', name: 'Guam', country_tld: '.gu'},
      {iso_code: 'GW', name: 'Guinea-Bissau', country_tld: '.gw'},
      {iso_code: 'GY', name: 'Guyana', country_tld: '.gy'},
      {iso_code: 'HK', name: 'Hong Kong', country_tld: '.hk'},
      {iso_code: 'HM', name: 'Heard Island and McDonald Islands', country_tld: '.hm'},
      {iso_code: 'HN', name: 'Honduras', country_tld: '.hn'},
      {iso_code: 'HR', name: 'Croatia', country_tld: '.hr', in_the_eu: true},
      {iso_code: 'HT', name: 'Haiti', country_tld: '.ht'},
      {iso_code: 'HU', name: 'Hungary', country_tld: '.hu', in_the_eu: true},
      {iso_code: 'ID', name: 'Indonesia', country_tld: '.id'},
      {iso_code: 'IE', name: 'Ireland', country_tld: '.ie', in_the_eu: true},
      {iso_code: 'IL', name: 'Israel', country_tld: '.il'},
      {iso_code: 'IM', name: 'Isle of Man', country_tld: '.im'},
      {iso_code: 'IN', name: 'India', country_tld: '.in'},
      {iso_code: 'IO', name: 'British Indian Ocean Territory', country_tld: '.io'},
      {iso_code: 'IQ', name: 'Iraq', country_tld: '.iq'},
      {iso_code: 'IR', name: 'Iran', country_tld: '.ir'},
      {iso_code: 'IS', name: 'Iceland', country_tld: '.is'},
      {iso_code: 'IT', name: 'Italy', country_tld: '.it', in_the_eu: true},
      {iso_code: 'JE', name: 'Jersey', country_tld: '.je'},
      {iso_code: 'JM', name: 'Jamaica', country_tld: '.jm'},
      {iso_code: 'JO', name: 'Jordan', country_tld: '.jo'},
      {iso_code: 'JP', name: 'Japan', country_tld: '.jp'},
      {iso_code: 'KE', name: 'Kenya', country_tld: '.ke'},
      {iso_code: 'KG', name: 'Kyrgyzstan', country_tld: '.kg'},
      {iso_code: 'KH', name: 'Cambodia', country_tld: '.kh'},
      {iso_code: 'KI', name: 'Kiribati', country_tld: '.ki'},
      {iso_code: 'KM', name: 'Comoros', country_tld: '.km'},
      {iso_code: 'KN', name: 'Saint Kitts and Nevis', country_tld: '.kn'},
      {iso_code: 'KP', name: 'North Korea', country_tld: '.kp'},
      {iso_code: 'KR', name: 'South Korea', country_tld: '.kr'},
      {iso_code: 'KW', name: 'Kuwait', country_tld: '.kw'},
      {iso_code: 'KY', name: 'Cayman Islands', country_tld: '.ky'},
      {iso_code: 'KZ', name: 'Kazakhstan', country_tld: '.kz'},
      {iso_code: 'LA', name: 'Laos', country_tld: '.la'},
      {iso_code: 'LB', name: 'Lebanon', country_tld: '.lb'},
      {iso_code: 'LC', name: 'Saint Lucia', country_tld: '.lc'},
      {iso_code: 'LI', name: 'Liechtenstein', country_tld: '.li'},
      {iso_code: 'LK', name: 'Sri Lanka', country_tld: '.lk'},
      {iso_code: 'LR', name: 'Liberia', country_tld: '.lr'},
      {iso_code: 'LS', name: 'Lesotho', country_tld: '.ls'},
      {iso_code: 'LT', name: 'Lithuania', country_tld: '.lt', in_the_eu: true},
      {iso_code: 'LU', name: 'Luxembourg', country_tld: '.lu', in_the_eu: true},
      {iso_code: 'LV', name: 'Latvia', country_tld: '.lv', in_the_eu: true},
      {iso_code: 'LY', name: 'Libya', country_tld: '.ly'},
      {iso_code: 'MA', name: 'Morocco', country_tld: '.ma'},
      {iso_code: 'MC', name: 'Monaco', country_tld: '.mc'},
      {iso_code: 'MD', name: 'Moldova', country_tld: '.md'},
      {iso_code: 'ME', name: 'Montenegro', country_tld: '.me'},
      {iso_code: 'MF', name: 'Saint Martin (French part)', country_tld: '.mf'},
      {iso_code: 'MG', name: 'Madagascar', country_tld: '.mg'},
      {iso_code: 'MH', name: 'Marshall Islands', country_tld: '.mh'},
      {iso_code: 'MK', name: 'FYROM', country_tld: '.mk'},
      {iso_code: 'ML', name: 'Mali', country_tld: '.ml'},
      {iso_code: 'MM', name: 'Myanmar', country_tld: '.mm'},
      {iso_code: 'MN', name: 'Mongolia', country_tld: '.mn'},
      {iso_code: 'MO', name: 'Macao', country_tld: '.mo'},
      {iso_code: 'MP', name: 'Northern Mariana Islands', country_tld: '.mp'},
      {iso_code: 'MQ', name: 'Martinique', country_tld: '.mq'},
      {iso_code: 'MR', name: 'Mauritania', country_tld: '.mr'},
      {iso_code: 'MS', name: 'Montserrat', country_tld: '.ms'},
      {iso_code: 'MT', name: 'Malta', country_tld: '.mt', in_the_eu: true},
      {iso_code: 'MU', name: 'Mauritius', country_tld: '.mu'},
      {iso_code: 'MV', name: 'Maldives', country_tld: '.mv'},
      {iso_code: 'MW', name: 'Malawi', country_tld: '.mw'},
      {iso_code: 'MX', name: 'Mexico', country_tld: '.mx'},
      {iso_code: 'MY', name: 'Malaysia', country_tld: '.my'},
      {iso_code: 'MZ', name: 'Mozambique', country_tld: '.mz'},
      {iso_code: 'NA', name: 'Namibia', country_tld: '.na'},
      {iso_code: 'NC', name: 'New Caledonia', country_tld: '.nc'},
      {iso_code: 'NE', name: 'Niger', country_tld: '.ne'},
      {iso_code: 'NF', name: 'Norfolk Island', country_tld: '.nf'},
      {iso_code: 'NG', name: 'Nigeria', country_tld: '.ng'},
      {iso_code: 'NI', name: 'Nicaragua', country_tld: '.ni'},
      {iso_code: 'NL', name: 'Netherlands', country_tld: '.nl', in_the_eu: true},
      {iso_code: 'NO', name: 'Norway', country_tld: '.no'},
      {iso_code: 'NP', name: 'Nepal', country_tld: '.np'},
      {iso_code: 'NR', name: 'Nauru', country_tld: '.nr'},
      {iso_code: 'NU', name: 'Niue', country_tld: '.nu'},
      {iso_code: 'NZ', name: 'New Zealand', country_tld: '.nz'},
      {iso_code: 'OM', name: 'Oman', country_tld: '.om'},
      {iso_code: 'PA', name: 'Panama', country_tld: '.pa'},
      {iso_code: 'PE', name: 'Peru', country_tld: '.pe'},
      {iso_code: 'PF', name: 'French Polynesia', country_tld: '.pf'},
      {iso_code: 'PG', name: 'Papua New Guinea', country_tld: '.pg'},
      {iso_code: 'PH', name: 'Philippines', country_tld: '.ph'},
      {iso_code: 'PK', name: 'Pakistan', country_tld: '.pk'},
      {iso_code: 'PL', name: 'Poland', country_tld: '.pl', in_the_eu: true},
      {iso_code: 'PM', name: 'Saint Pierre and Miquelon', country_tld: '.pm'},
      {iso_code: 'PN', name: 'Pitcairn', country_tld: '.pn'},
      {iso_code: 'PR', name: 'Puerto Rico', country_tld: '.pr'},
      {iso_code: 'PS', name: 'Palestine, State of', country_tld: '.ps'},
      {iso_code: 'PT', name: 'Portugal', country_tld: '.pt', in_the_eu: true},
      {iso_code: 'PW', name: 'Palau', country_tld: '.pw'},
      {iso_code: 'PY', name: 'Paraguay', country_tld: '.py'},
      {iso_code: 'QA', name: 'Qatar', country_tld: '.qa'},
      {iso_code: 'RE', name: 'Reunion', country_tld: '.re'},
      {iso_code: 'RO', name: 'Romania', country_tld: '.ro', in_the_eu: true},
      {iso_code: 'RS', name: 'Serbia', country_tld: '.rs'},
      {iso_code: 'RU', name: 'Russia', country_tld: '.ru'},
      {iso_code: 'RW', name: 'Rwanda', country_tld: '.rw'},
      {iso_code: 'SA', name: 'Saudi Arabia', country_tld: '.sa'},
      {iso_code: 'SB', name: 'Solomon Islands', country_tld: '.sb'},
      {iso_code: 'SC', name: 'Seychelles', country_tld: '.sc'},
      {iso_code: 'SD', name: 'Sudan', country_tld: '.sd'},
      {iso_code: 'SE', name: 'Sweden', country_tld: '.se', in_the_eu: true},
      {iso_code: 'SG', name: 'Singapore', country_tld: '.sg'},
      {iso_code: 'SH', name: 'Saint Helena, Ascension and Tristan da Cunha', country_tld: '.sh'},
      {iso_code: 'SI', name: 'Slovenia', country_tld: '.si', in_the_eu: true},
      {iso_code: 'SJ', name: 'Svalbard and Jan Mayen', country_tld: '.sj'},
      {iso_code: 'SK', name: 'Slovakia', country_tld: '.sk', in_the_eu: true},
      {iso_code: 'SL', name: 'Sierra Leone', country_tld: '.sl'},
      {iso_code: 'SM', name: 'San Marino', country_tld: '.sm'},
      {iso_code: 'SN', name: 'Senegal', country_tld: '.sn'},
      {iso_code: 'SO', name: 'Somalia', country_tld: '.so'},
      {iso_code: 'SR', name: 'Suriname', country_tld: '.sr'},
      {iso_code: 'SS', name: 'South Sudan', country_tld: '.ss'},
      {iso_code: 'ST', name: 'Sao Tome and Principe', country_tld: '.st'},
      {iso_code: 'SV', name: 'El Salvador', country_tld: '.sv'},
      {iso_code: 'SX', name: 'Sint Maarten (Dutch part)', country_tld: '.sx'},
      {iso_code: 'SY', name: 'Syria', country_tld: '.sy'},
      {iso_code: 'SZ', name: 'Swaziland', country_tld: '.sz'},
      {iso_code: 'TC', name: 'Turks and Caicos Islands', country_tld: '.tc'},
      {iso_code: 'TD', name: 'Chad', country_tld: '.td'},
      {iso_code: 'TF', name: 'French Southern Territories', country_tld: '.tf'},
      {iso_code: 'TG', name: 'Togo', country_tld: '.tg'},
      {iso_code: 'TH', name: 'Thailand', country_tld: '.th'},
      {iso_code: 'TJ', name: 'Tajikistan', country_tld: '.tj'},
      {iso_code: 'TK', name: 'Tokelau', country_tld: '.tk'},
      {iso_code: 'TL', name: 'East Timor', country_tld: '.tl'},
      {iso_code: 'TM', name: 'Turkmenistan', country_tld: '.tm'},
      {iso_code: 'TN', name: 'Tunisia', country_tld: '.tn'},
      {iso_code: 'TO', name: 'Tonga', country_tld: '.to'},
      {iso_code: 'TR', name: 'Turkey', country_tld: '.tr'},
      {iso_code: 'TT', name: 'Trinidad and Tobago', country_tld: '.tt'},
      {iso_code: 'TV', name: 'Tuvalu', country_tld: '.tv'},
      {iso_code: 'TW', name: 'Taiwan, Province of China', country_tld: '.tw'},
      {iso_code: 'TZ', name: 'Tanzania', country_tld: '.tz'},
      {iso_code: 'UA', name: 'Ukraine', country_tld: '.ua'},
      {iso_code: 'UG', name: 'Uganda', country_tld: '.ug'},
      {iso_code: 'UM', name: 'United States Minor Outlying Islands', country_tld: '.um'},
      {iso_code: 'US', name: 'United States', country_tld: '.us'},
      {iso_code: 'UY', name: 'Uruguay', country_tld: '.uy'},
      {iso_code: 'UZ', name: 'Uzbekistan', country_tld: '.uz'},
      {iso_code: 'VA', name: 'Vatican City', country_tld: '.va'},
      {iso_code: 'VC', name: 'Saint Vincent and Grenadines', country_tld: '.vc'},
      {iso_code: 'VE', name: 'Venezuela', country_tld: '.ve'},
      {iso_code: 'VG', name: 'Virgin Islands, British', country_tld: '.vg'},
      {iso_code: 'VI', name: 'Virgin Islands, U.S.', country_tld: '.vi'},
      {iso_code: 'VN', name: 'Vietnam', country_tld: '.vn'},
      {iso_code: 'VU', name: 'Vanuatu', country_tld: '.vu'},
      {iso_code: 'WF', name: 'Wallis and Futuna', country_tld: '.wf'},
      {iso_code: 'YE', name: 'Yemen', country_tld: '.ye'},
      {iso_code: 'YT', name: 'Mayotte', country_tld: '.yt'},
      {iso_code: 'ZA', name: 'South Africa', country_tld: '.za'},
      {iso_code: 'ZM', name: 'Zambia', country_tld: '.zm'},
      {iso_code: 'ZW', name: 'Zimbabwe', country_tld: '.zw'},
      {iso_code: 'XK', name: 'Kosovo', country_tld: '---'}
  ]
  countries.each_with_index do |country, counter|
    Country.where(name: country[:name]).first_or_create!(
        country.merge(sorting_order: ((counter * 10) + 1000), currency_id: 3, continent: 'Europe')
    ); print "#{country[:name]} "
  end

  europe = %w(AD AL AM AT AZ BA BE BG BY CH CY CZ DE DK EE ES FI FO FR GB GE GG GI GR HR HU IE IM IS IT JE LI LT LU LV MC MD ME MK MT NL NO PL PT RO RS RU SE SI SJ SK SM UA VA XK)
  africa = %w(AO BF BI BJ BW CD CF CG CI CV DJ DZ EH ER ET GA GH GM GN GQ GW KE KM LR LS MA MG ML MR MU MW MZ NA NE NG RE RW SC SD SH SL SN SO SS ST SZ TD TG TN UG YT ZA ZM ZW)
  asia = %w(AE AF BD BH BN BT CN EG GM HK IL IN IO IQ IR JN JO JP KG KH KP KR KW KZ LA LB LK LY MM MN MO MP MV MY NP OM PF PH PK PS PW QA SA SG SY TH TJ TL TM TR TW UZ VN YE)
  north_america = %w(BM CA MX GL PM US)
  central_america = %w(AG BL AI AW AX BB BQ BS BV BZ CC CK CM CR CU CW CX DM DO GD GP GS GT GU HN HT JM KN KY LC MF MH MQ NI PA PR SV SX TC TT UM VG VI)
  south_america = %w(AR BO BR CL CO EC FK GF GY MS PE PY SR UY VC VE)
  australia = %w(AS WS AU FJ FM ID KI NC NF NR NU NZ PG PN SB TK TO TV TZ VU WF)
  antarctic = %w(AQ HM TF)

  Country.where(iso_code: europe).update_all(continent: 'Europe')
  Country.where(iso_code: africa).update_all(continent: 'Africa')
  Country.where(iso_code: asia).update_all(continent: 'Asia')
  Country.where(iso_code: north_america).update_all(continent: 'North America')
  Country.where(iso_code: central_america).update_all(continent: 'Central America')
  Country.where(iso_code: south_america).update_all(continent: 'South America')
  Country.where(iso_code: australia).update_all(continent: 'Australia')
  Country.where(iso_code: antarctic).update_all(continent: 'Antarctic')
  if Country.where(continent: nil).count > 0
    print 'COUNTRIES WITH NO CONTINENT: '
    puts Country.where(continent: nil).map(&:iso_code).join(', ')
  end

  Country.all_in_eu.each_with_index do |country, counter|
    country.update_attributes!(sorting_order: (counter * 10) + 100,
                              currency_id: 1, continent: 'Europe')
    print '.'
  end
  Country.find_by_name('Ireland').update_attributes(sorting_order: 10)
  Country.find_by_name('United Kingdom').update_attributes(sorting_order: 20, currency_id: 2)
  Country.find_by_name('United States').update_attributes(sorting_order: 30)
  Country.find_by_name('Canada').update_attributes(sorting_order: 40)

  puts ' DONE'

  print 'Assign Currencies to Countries: '
  # Currency: 1=eur, 2=gbp, 3=usd -- see above
  Country.where(continent: ['North America', 'Central America', 'South America']).update_all(currency_id: 3); print '.'
  Country.where(continent: 'Europe').update_all(currency_id: 1); print '.'
  Country.where(iso_code: %w(GB IM JE GG GI)).update_all(currency_id: 2); print '.'
  Country.where(continent: %w(Africa Asia Australia Antarctic)).update_all(currency_id: 2); print '.'
  puts ' DONE'

  puts
  puts 'Completed the db/seed process'
  puts '*' * 100

end
