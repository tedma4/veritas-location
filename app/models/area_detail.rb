class AreaDetail
	include Mongoid::Document
	embedded_in :area
	# Description - Description(AreaDetail)
	field :description, type: String
	# Place type (Restaurant, Shopping Center, Convenience Store, Etc ), Etc - PlaceDetail(AreaDetail)
	# Place detail will be a category and the corresponding labels to that category
	field :place_detail, type: Hash, default: Hash.new
	field :place_type, type: String
	# Address - Address(AreaDetail)
	field :address, type: String
	# Link to website - Website(AreaDetail)
	field :website, type: String
	# Phone Number - PhoneNumber(AreaDetail)
	field :phone_number, type: String
	# Phone Number - PhoneNumber(AreaDetail)
	field :email, type: String
end