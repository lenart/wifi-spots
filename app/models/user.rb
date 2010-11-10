# TODO Use Observer to deliver signup email

class User < ActiveRecord::Base
  
  acts_as_authentic do |config|
    # config.validate_login_field = false
    # config.validates_length_of_login_field_options = { :within => 2..5 }
    config.validate_email_field    = false
    config.validate_login_field    = false
    config.validate_password_field = false
  end
  
  include Profile
  
  has_many :spots, :dependent => :destroy
  
  def admin?
    %w(lenart.rudel@gmail.com nina.kozar@gmail.com blazek@gmail.com).include? self.email
  end
  
  def full_name
    return name unless name.blank?
    return email
  end
    
end