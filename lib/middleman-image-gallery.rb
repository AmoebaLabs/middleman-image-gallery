
module MiddlemanImageGallery

  def MiddlemanImageGallery.gallery
    gallery = ImageGallery.new('images/path-to-images')

    puts gallery.imagePath()
  end

  def MiddlemanImageGallery.version
    MiddlemanImageGallery::VERSION
  end

end

require "middleman_image_gallery/version"
require "middleman_image_gallery/image_gallery"
