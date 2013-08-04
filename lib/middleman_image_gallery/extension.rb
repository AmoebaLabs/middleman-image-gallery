require "middleman-core"
require 'middleman_image_gallery/thumbnail_generator'
require 'middleman_image_gallery/helpers'

module Middleman

  class ThumbnailExtension < Extension
    def initialize(app, options_hash={}, &block)
      super

      # after build callback
      app.after_build do |builder|
        writer = ThumbnailWriter.new(self)
        writer.write
      end
    end

    # exposed helper to create a gallery
    # put this in your erb file
    # <%= gallery_div(data.gallery.gallery-name, "section-name") %>
    helpers do
      def gallery_div(data, name, opts={})
        gallery = GalleryGenerator.new(self)
        gallery.gen(data, name, opts)
      end
    end

  end
end

::Middleman::Extensions.register(:image_gallery, Middleman::ThumbnailExtension)


