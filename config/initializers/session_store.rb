# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wifi-spots_session',
  :secret      => '48369260911297ff80591f5080b37374801c84ec6acbe64e0a60c92341d5a5b405b1d19cfc88a7936f9a0885e9d980ce385880d6bad5478dd9a0d7372dfb5103'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
