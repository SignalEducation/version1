Currency.where(id: 1).first_or_create(
          iso_code: 'EUR', name: 'Euro',
          leading_symbol: '€', trailing_symbol: 'c',
          active: true, sorting_order: 100); print '.'
Currency.where(id: 2).first_or_create(
          iso_code: 'GBP', name: 'Pounds Sterling',
          leading_symbol: '£', trailing_symbol: 'p',
          active: true, sorting_order: 200); print '.'
Currency.where(id: 3).first_or_create(
          iso_code: 'USD', name: 'US Dollar',
          leading_symbol: '$', trailing_symbol: 'c',
          active: true, sorting_order: 300); print '.'
Currency.where(id: 4).first_or_create(
          iso_code: 'CAD', name: 'Canadian Dollar',
          leading_symbol: '$', trailing_symbol: 'c',
          active: false, sorting_order: 400); print '.'
Currency.where(id: 5).first_or_create(
          iso_code: 'HKD', name: 'Hong Kong Dollar',
          leading_symbol: '$', trailing_symbol: 'c',
          active: false, sorting_order: 500); print '.'
Currency.where(id: 6).first_or_create(
          iso_code: 'SGD', name: 'Singapore Dollar',
          leading_symbol: '$', trailing_symbol: 'c',
          active: false, sorting_order: 600); print '.'

puts 'Assign Currencies to Countries: '
# Currency: 1=eur, 2=gbp, 3=usd -- see above
Country.where(continent: ['North America', 'Central America', 'South America']).update_all(currency_id: 3); print '.'
Country.where(continent: 'Europe').update_all(currency_id: 1); print '.'
Country.where(iso_code: %w(GB IM JE GG GI)).update_all(currency_id: 2); print '.'
Country.where(continent: %w(Africa Asia Australia Antarctic)).update_all(currency_id: 2); print '.'

