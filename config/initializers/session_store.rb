# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wifi_spots_session',
  :secret      => 'c79a4f30458882644e21be84b78698dd95cafc71c949114a238307b00d8e480559698e725b8eac9ea85fe659e5138d4b866bda0499d30995ba50c8573af3a5f0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
