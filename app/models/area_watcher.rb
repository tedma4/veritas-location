class AreaWatcher
	include Mongoid::Document
	include Mongoid::Timestamps
	belongs_to :area, index: true
	field :user_id, type: String, index: true
	field :first_coord_time_stamp, type: DateTime
	field :last_coord_time_stamp, type: DateTime
	field :finished, type: Boolean, default: false
	field :visit_type, type: String # "full_visit", "single_visit", "continued_visit"

	field :pre_selection_stage, type: Boolean, default: true
	field :pre_selection_count, type: Integer, default: 1
end