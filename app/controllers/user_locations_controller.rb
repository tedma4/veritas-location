class UserLocationsController < ApplicationController

	def index
		@users = UserLocation.all 
		render json: @users.map(&:build_user_location_hash)
	end

end