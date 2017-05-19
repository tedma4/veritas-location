class ImageString 
	require 'open-uri'
	require 'faker'
  require 'base64'

	def self.image_file
    open(Faker::Avatar.image(Faker::Name.first_name, 
		"300x300",
		"jpg", 
		"set#{%w(1 2 3).sample}",
		"bg#{%w(1 2).sample}"
		),
		{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
	end

	def self.base64_image
		faker_image = Faker::Avatar.image(Faker::Name.first_name, 
		"300x300",
		"jpg", 
		"set#{%w(1 2 3).sample}",
		"bg#{%w(1 2).sample}"
		)
		Base64.encode64(open(faker_image,
		{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)
	end
end


#Encode an image from a link and upload an image from a link

# require 'open-uri'
# require 'faker'

# user = User.new
# user.first_name = Faker::Name.first_name
# user.last_name = Faker::Name.last_name
# # the open method creates a tmp file from the url given to it
# # This allows the console to be able to upload an image from the created file
# user.avatar = 
# open(Faker::Avatar.image("Ted", 
#   "300x300",
#   "jpg", 
#   "set2",
#   "bg2"
#   ),
#   {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
# user.save(validate: false)

# # Build a Base64 encoded image

# require 'base64'

# Base64.encode64(open(Faker::Avatar.image('Ted', 
#   "300x300",
#   "jpg", 
#   "set2",
#   "bg2"
#   ), {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)