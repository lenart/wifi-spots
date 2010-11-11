class OauthToken < AccessToken
  
  def client
    unless @client
      if oauth_version == 1.0
        @client = OAuth::AccessToken.new(self.consumer, self.token, self.secret)
      else
        @client = OAuth2::AccessToken.new(self.consumer, self.token)
      end
    end
    
    @client
  end
  
  def clear
    @client = nil
  end
  
  def oauth_version
    self.class.oauth_version
  end
  
  def get(path, headers = {})
    client.get(path, headers)
  end
  
  def post(path, body = "", headers = {})
    client.post(path, body, headers)
  end
  
  def head(path, headers = {})
    client.head(path, headers)
  end
  
  def put(path, body = "", headers = {})
    client.put(path, body, headers)
  end
  
  def delete(path, headers = {})
    client.delete(path, headers)
  end
  
  class << self
    
    # oauth version, 1.0 or 2.0
    def version(value)
      @oauth_version = value
    end
    
    def oauth_version
      @oauth_version ||= 1.0
    end
    
    # unique key that we will use from the AccessToken response
    # to identify the user by.
    # in Twitter, its "user_id".  Twitter has "screen_name", but that's
    # more subject to change than user_id.  Pick whatever is least likely to change
    def key(value = nil, &block)
      if block_given?
        @oauth_key = block
      else
        @oauth_key = value.is_a?(Symbol) ? value : value.to_sym
      end
    end
    
    def oauth_key
      @oauth_key
    end
    
    def config
      super.merge(credentials[:options] || {})
    end

    def consumer
      if oauth_version == 1.0
        OAuth::Consumer.new(credentials[:key], credentials[:secret], config)
      else
        OAuth2::Client.new(credentials[:key], credentials[:secret], config)
      end
    end
    
    # if we're lucky we can find it by the token.
    def find_by_key_or_token(key, token, options = {})
      result = self.find_by_key(key, options) unless key.nil?
      unless result
        if !token.blank? && self.respond_to?(:find_by_token)
          result = self.find_by_token(token, options)
        end
      end
      result 
    end
    
    # this is a wrapper around oauth 1 and 2.
    # it looks obscure, but from the api point of view
    # you won't have to worry about it's implementation.
    # in oauth 1.0, key = oauth_token, secret = oauth_secret
    # in oauth 2.0, key = code, secret = access_token
    def get_token_and_secret(options = {})
      oauth_verifier  = options[:oauth_verifier]
      redirect_uri    = options[:redirect_uri]
      token           = options[:token]
      secret          = options[:secret]
      consumer        = self.consumer # cached
      
      if oauth_version == 1.0
        access = request_token(token, secret).get_access_token(:oauth_verifier => oauth_verifier)
        result = {:token => access.token, :secret => access.secret, :key => nil}
        if self.oauth_key
          if oauth_key.is_a?(Proc)
            result[:key] = oauth_key.call(access)
          else
            result[:key] = access.params[self.oauth_key] || access.params[self.oauth_key.to_s] # try both
          end
        else
          puts "Access Token: #{access.inspect}"
          raise "please set an oauth key for #{service_name.to_s}"
        end
      else
        access = consumer.web_server.get_access_token(secret, :redirect_uri => redirect_uri)
        result = {:token => access.token, :secret => secret, :key => nil}
      end
      
      result
    end
    
    # this is a cleaner method so we can access the authorize_url
    # from oauth 1 or 2
    def authorize_url(callback_url, &block)
      consumer        = self.consumer # cached

      if oauth_version == 1.0
        request = get_request_token(callback_url, consumer)
        yield request if block_given?
        return request.authorize_url
      else
        options = {:redirect_uri => callback_url}

        unless consumer.nil? || consumer.options.empty? || consumer.options[:scope].nil?
          options[:scope] = consumer.options[:scope]
        else
          options[:scope] = self.config[:scope] unless self.config[:scope].blank?
        end
        return consumer.web_server.authorize_url(options)
      end
    end
    
    def request_token(token, secret)
      OAuth::RequestToken.new(consumer, token, secret)
    end
    
    # if you pass a hash as the second parameter to consumer.get_request_token,
    # ruby oauth will think this is a form and all sorts of bad things happen
    def get_request_token(callback_url, consumer = nil)
      options = {:scope => config[:scope]} if config[:scope]
      consumer ||= self.consumer
      consumer.get_request_token({:oauth_callback => callback_url}, options)
    end
    
    def get_access_token(oauth_verifier)
      request_token.get_access_token(:oauth_verifier => oauth_verifier)
    end
  end
  
end
