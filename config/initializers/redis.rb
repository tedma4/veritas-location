if Rails.env == "development"
	$redis = Redis.new
else
	uri = URI.parse(ENV['REDISTOGO_URL'])
	$redis = Redis.new(url: uri)
end