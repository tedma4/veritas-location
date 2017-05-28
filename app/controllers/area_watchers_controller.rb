class AreaWatchersController < ApplicationController

  def user_location
    # http://localhost:3000/user_location?user_id=5856d773c2382f415081e8cd&location=-111.97798311710358,33.481907631522525&time_stamp=2017-01-15T18:01:24.734-07:00    
    if @current_user
      coords = AreaWatcher.add_location_data(@current_user.id, params[:location], params[:time_stamp])
      @current_user.area_watcher(coords)
      render json: {status: 200} #, auth_token: encoded_token}
    else
      render json: {errors: 400}
    end
  end
end