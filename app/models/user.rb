# TODO Use Observer to deliver signup email

class User < ActiveRecord::Base
  
  acts_as_authentic do |c|
    # c.validate_login_field = false
    # c.validates_length_of_login_field_options = { :within => 2..5 }
  end
  
  has_many :spots, :dependent => :destroy
  
  def admin?
    %w(lenart.rudel@gmail.com lenart.rudel@o2z2.com).include? self.email
  end
  
  def full_name
    return name unless name.blank?
    return email
  end
    
  def self.quick_create(email)
    pass = generate_password
    user = User.create(:email => email, :password => pass, :password_confirmation => pass)
    
    UserMailer.deliver_anonymous_signup_notification(user) if user.valid?
    
    return user
  end
  

###########################
# PRIVATE
###########################
  
  private
    
    def self.generate_password
      # generate a random 8 digit password
      Authlogic::Random.friendly_token[0..7]
    end

end