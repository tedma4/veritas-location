class AreasController < ApplicationController
	before_action :set_area, only: [:update, :delete, :show, :feed, :edit]

	def new
		@area = Area.new
		@areas = Area.where(:level.nin => ["L0"]).map { |area| 
			map = { 
				coords: area.area_profile[:coordinates][0].map {|points| {lat: points.last, lng: points.first} }, 
				level: area.level,
				title: area.title,
				id: area.id.to_s
		  }
		  map[:attachment] = area.attachment.url if area.attachment
		  map
		}
	end

	def feed
		@area = Area.includes(:area_watchers, {area_watchers: :user}).find(params[:id])
		if ["L1", "L0"].include? @area.level 
			@inner_areas = Area.where(
	      area_profile: {
	        "$geoWithin" => {
	          "$geometry"=> {
	            type: "Polygon",
	            coordinates: @area.area_profile[:coordinates]
	      }}},
	      :id.nin => [@area.id]
	    )
		elsif @area.level == "L2"
			@outer_areas = Area.where(
	      area_profile: {
	        "$geoIntersects" => {
	          "$geometry"=> {
	            type: "Polygon",
	            coordinates: @area.area_profile[:coordinates]
	      }}},
	      :id.nin => [@area.id]
	    )
		end
	end

	def show
		locs = UserLocation.where(:"coords" => {"$geoIntersects" => { "$geometry" => @area.area_profile } })
		@polygon = @area.to_a.map { |area| 
			{ 
				coords: area.area_profile[:coordinates][0].map {|points| {lat: points.last, lng: points.first} }, 
				level: area.level,
				title: area.title,
				id: area.id.to_s,
		  }
		}.first
		@dots = locs.pluck(:coords).map {|l| {position: {lat: l[1], lng: l[0]}, type: "user"} }
	end

	def create
		@area = Area.new(area_params)
		@area.area_detail = AreaDetail.new 

		if @area.save
			## After an area is successfully saved add it to the corresponding 
			## location details
			# @area.create_other_things
			render json: {status: 200}
		else
			render json: @area.errors, status: :unprocessable_entity
		end				
	end

	def edit

	end

	def update
		if @area.update(area_params)
			## After an area is successfully saved add it to the corresponding 
			## location details
			# @area.update_other_things
			render json: @area, notice: 'Area was successfully Updated.'
		else
			render json: @area.errors, status: :unprocessable_entity
		end
  end

  def index
		areas = Area.pluck(:area_profile, :title, :level, :id)
		@areas = areas.map {|area|
			{
				coords: area[0][:coordinates][0].map {|points| {lat: points.last, lng: points.first} }, 
				dot_count: UserLocation.where(:"coords" => {"$geoIntersects" => { "$geometry" => area[0] } }).count,
				title: area[1],
				level: area[2],
				id: area[3].to_s
			}
		}
		render json: @areas
  end

  def delete
  	@area.destroy
  end

	private

	def set_area
		@area = Area.find(params[:id])
	end

	def area_params
		category_keys = params[:area][:area_detail][:place_detail].try(:keys) if params[:area][:area_detail]
		the_params = params.require(:area).permit(:title, :area_profile, :level, :attachment, {area_detail: [:description, :address, :website, :phone_number, :email, :place_type, {place_detail: category_keys } ]})
		the_params[:area_profile] = Area.profile_maker(params[:area][:area_profile]) if params[:area][:area_profile]
		return the_params
	end
end
