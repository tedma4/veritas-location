# uri = "mongodb://tedma4:tm671216@ds133428.mlab.com:33428/veritas_db"
# client = Mongo::Client.new(uri)
# db = client.database
# db.collections
# Read from the connected db


c[:areas].find.limit(100).each do |doc|
	a = Area.new
	a.area_profile = doc[:area_profile]
	a.title = doc[:title]
	a.level = doc[:level]
	a.save
end

Area.where(area_profile: {"$geoIntersects" => {"$geometry"=> {type: "Point", coordinates: [-112.07474560000003,33.5055259] }}}).first

c = Mongo::Client.new("mongodb://tedma4:tm671216@ds133428.mlab.com:33428/veritas_db")
collection = c[:areas]
d = collection.find( {"area_profile": {"$geoIntersects": {"$geometry": {type: "Point", coordinates: [-112.07474560000003,33.5055259]}}}} )








# coordinates here "-112.07474560000003,33.5055259"
# coordinates here [-112.07474560000003,33.5055259]
