class StringImageUploader
	def initialize(string, calling_class)
		@string = string
		@calling_class = calling_class
	end

  def parse_image_data
    filename = "upload-#{@calling_class}"
    # in_content_type, encoding, string = string.split(/[:;,]/)[0..3]

    @tempfile = Tempfile.new(filename)
    @tempfile.binmode
    @tempfile.write Base64.decode64(@string)
    @tempfile.rewind

    # for security we want the actual content type, not just what was passed in
    content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

    # we will also add the extension ourselves based on the above
    # if it's not gif/jpeg/png, it will fail the validation in the upload model
    extension = content_type.match(/gif|jpeg|png/).to_s
    filename += ".#{extension}" if extension

    ActionDispatch::Http::UploadedFile.new({
                                               tempfile: @tempfile,
                                               content_type: content_type,
                                               filename: filename
                                           })
  end

  def clean_tempfile
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end
end