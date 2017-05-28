class ApplicationController < ActionController::API
  # include ActionController::ImplicitRender
  # respond_to :json

  before_action :authenticate_user_from_token!
  require 'json_web_token'

  def authenticate_user_from_token!
    if claims and @current_user = valid_session?(claims)
      @current_user
    else
      render json: {errors: { unauthorized: ["You can't do that"] }}, status: 401
    end
  end

  def jwt_token(user)
    # ex: {data: {user_id: "1234567890987654321"}}
    JsonWebToken.encode(user)
  end

  def valid_session?(claims)
    session = claims[:data][:user_id]
    if session
      return session # Need to update to become the current user_id
    else
      return false
    end
  end

  protected

  def claims
    auth_header = request.headers['HTTP_AUTHORIZATION'] and ::JsonWebToken.decode(auth_header)
  rescue
    nil
  end
end
