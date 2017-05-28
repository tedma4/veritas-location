class Area
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial
  mount_uploader :attachment, AttachmentUploader
  delegate :url, :size, :path, to: :attachment
  has_many :area_watchers, dependent: :destroy
  field :attachment, type: String#, null: false  
  field :area_profile, type: Polygon, sphere: true
  field :title, type: String, default: "Name of Area"
  field :level, type: String, default: "l2"
  field :chat_ids, type: Array, default: Array.new
  embeds_one :area_detail

  def has_coords?(coords)
    rgeo = RGeo::Geographic.simple_mercator_factory
    if coords.is_a? Array
      if !coords.first.is_a? Float
        points = coords.map {|point|
          if point.is_a? Mongoid::Geospatial::Point
            rgeo.point(point.x, point.y)
          elsif point.is_a? UserLocation
            rgeo.point(point.coords.x, point.coords.y)
          else
            rgeo.point(point.first, point.last)
          end
        }
      else
        points = rgeo.point(coords.first, coords.last)
        points = [points]
      end
      area_profile_points = self.area_profile[:coordinates][0].map {|point| 
        rgeo.point(point.first, point.last)
      }
      area_polygon = rgeo.polygon rgeo.line_string(area_profile_points)
      points.any? {|point| area_polygon.contains? point }
    else
      if coords.is_a? Mongoid::Geospatial::Point
        point = rgeo.point(coords.x, coords.y)
      elsif coords.is_a? UserLocation
        point = rgeo.point(coords.coords.x, coords.coords.y)
      else
        point = rgeo.point(coords.first, coords.last)
      end
      area_profile_points = self.area_profile[:coordinates][0].map {|point| 
        rgeo.point(point.first, point.last)
      }
      area_polygon = rgeo.polygon rgeo.line_string(area_profile_points)
      area_polygon.contains? point
    end
  end
  private

  def self.profile_maker(area_profile)
    # if the area_profile is a polygon
    saved_hash = {type: "Polygon"}
    if area_profile.count > 2
      shape = area_profile.map{|coords| coords.split(",").map(&:to_f).reverse}
      shape << shape.first
      saved_hash[:coordinates] = [shape]
    else
      # if the area_profile is a rectangle
      north = area_profile.first.split(",").map(&:to_f)
      northWest = {lat: north.first, lng: north.last}
      south = area_profile.last.split(",").map(&:to_f)
      southEast = {lat: south.first, lng: south.last}
      northEast = {lat: northWest[:lat], lng: southEast[:lng] }
      southWest = {lat: southEast[:lat], lng: northWest[:lng] }

      # northWest, southWest, southEast, northEast, northWest
      shape = [
        [northWest[:lng], northWest[:lat]], 
        [southWest[:lng], southWest[:lat]], 
        [southEast[:lng], southEast[:lat]], 
        [northEast[:lng], northEast[:lat]], 
        [northWest[:lng], northWest[:lat]]
      ]
      saved_hash[:coordinates] = [shape]
    end
    return saved_hash
  end
end















