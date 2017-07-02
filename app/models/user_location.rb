class UserLocation
	include Mongoid::Document
	include Mongoid::Geospatial
	field :coords, type: Point, sphere: true
	field :time_stamp, type: DateTime
	field :user_id, type: String
	index({user_id: 1})
	# belongs_to :area, index: true

	def build_user_location_hash
		user = {
			id: self.id.to_s,
			user_id: self.user_id,
			location: self.coords,
			time_stamp: self.time_stamp
		}
		user
	end
end