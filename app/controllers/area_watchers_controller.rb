class AreaWatchersController < ApplicationController

  def user_location
    # http://localhost:3000/user_location?location=-111.97798311710358,33.481907631522525&time_stamp=2017-01-15T18:01:24.734-07:00    
    if @current_user
      coords = AreaWatcher.add_location_data(@current_user, params[:location], params[:time_stamp])
      AreaWatcher.watch_area(coords, @current_user)
      render json: {status: 200} #, auth_token: encoded_token}
    else
      render json: {errors: 400}
    end
  end
end