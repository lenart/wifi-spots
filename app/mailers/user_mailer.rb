# encoding: utf-8
# TODO Add header reply-to to capture bounced emails (at least for registration)
class UserMailer < ActionMailer::Base
  
  def signup_notification(user)
    setup
    
    from "info@wifi-tocke.si"
    recipients user.email
    subject "[WiFi točke] Podatki za dostop"
    
    body[:user] = user
    body[:login_url] = login_url
  end
  
  def anonymous_signup_notification(user)
    setup
    
    from "info@wifi-tocke.si"
    recipients user.email
    subject "[WiFi točke] Podatki za dostop"
    
    body[:user] = user
    body[:profile_url] = edit_user_url(user)
    body[:login_url] = login_url
  end
  
  # Used for sending e-mails to spot authors. Not used in wifi-tocke.si
  def message(recipient, sender, body)
    setup
    
    from       sender.email
    recipients recipient.email
    subject    "[WiFi točke] Sporočilo uporabnika #{sender.login}"
    bcc        "messages@wifi-tocke.si"
    
    @body[:recipient] = recipient
    @body[:sender] = sender.email
    @body[:content] = body
  end
  
  private
  
    def setup
      sent_on Time.now
      # content_type "multipart/alternative"
      content_type "text/html"
    end

end
