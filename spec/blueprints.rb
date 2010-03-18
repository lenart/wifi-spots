require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.email { Faker::Internet.email }
Sham.title { Faker::Lorem.words(3).join }

User.blueprint do
  email
  name { Faker::Name.name }
  
  password { 'secret' }
  password_confirmation { 'secret' }
  
  password_salt { Authlogic::Random.hex_token[0..39] }
  crypted_password { Authlogic::CryptoProviders::Sha512.encrypt(password + password_salt) }
  # persistence_token { Authlogic::Random.hex_token }
  # single_access_token { Authlogic::Random.friendly_token }
  # perishable_token { Authlogic::Random.friendly_token }
end

Spot.blueprint do
  title
  category
  # i.location
  # i.city
  notes { Faker::Lorem.paragraphs(2).join("\n") }
  user { User.make }
  lat 46.0620023
  lng 14.5096064
  zoom 8
  permalink "00047dc4f1b4ece888878"
end

Category.blueprint do
  name { Faker::Lorem.words(2).join(" ").capitalize }
  description { Faker::Lorem.paragraphs(2).join(" ") }
end