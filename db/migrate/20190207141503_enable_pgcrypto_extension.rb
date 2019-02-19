class EnablePgcryptoExtension < ActiveRecord::Migration[4.2][5.2]
  def change
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
  end
end
