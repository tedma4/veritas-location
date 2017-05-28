class UserLocation
	include Mongoid::Document
	include Mongoid::Geospatial
	field :coords, type: Point, sphere: true
	field :time_stamp, type: DateTime
	field :user_id, type: String
	index({user_id: 1})
	# belongs_to :area, index: true
end