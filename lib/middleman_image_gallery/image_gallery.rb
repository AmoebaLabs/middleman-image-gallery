module MiddlemanImageGallery

  class ImageGallery
    def initialize(imagePath)
      @imagePath = imagePath
    end

    def imagePath
      return @imagePath
    end
  end

end