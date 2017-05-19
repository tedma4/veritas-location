require 'jwt'

class JsonWebToken
  def self.encode(payload, expiration = 24.hours.from_now)
    payload = payload.dup
    # payload['exp'] = expiration.to_i
    # Setting a json web_token secret for now
    JWT.encode({data: payload}, Rails.application.secrets[:secret_key_base], "HS256")
  end

  def self.decode(token)
    decoded_token = JWT.decode(token, Rails.application.secrets[:secret_key_base], "HS256")
    return HashWithIndifferentAccess.new(decoded_token[0])
    rescue
      nil
  end
end