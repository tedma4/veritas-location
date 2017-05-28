# uri = "mongodb://tedma4:tm671216@ds133428.mlab.com:33428/veritas_db"
# client = Mongo::Client.new(uri)
# db = client.database
# db.collections
# Read from the connected db


client[:areas].find.limit(100).each do |doc|
	a = Area.new
	a.area_profile = doc[:area_profile]
	a.title = doc[:title]
	a.level = doc[:level]
	a.save
end

