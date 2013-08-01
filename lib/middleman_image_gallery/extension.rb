require "middleman-core"
require 'middleman_image_gallery/thumbnail_generator'

module Middleman

  class ThumbnailExtension < Extension
    def initialize(app, options_hash={}, &block)
      super

      # after build callback
      app.after_build do |builder|
      end

      # after configuration callback
      app.after_configuration do
        ThumbnailExtension.createThumbnails(self)
      end
    end

    private

    def self.createThumbnails(app)
      src = Pathname.new(File.join(app.source_dir, app.settings.images_dir, 'gallery'))

      file_types = [:jpg, :jpeg, :png]

      glob = "#{src}/*.{#{file_types.join(',')}}"
      files = Dir[glob]

      files.each do |file|
        filename = File.basename(file)

        dimensions = { small: '200x' }

        thumbsDirectory = Pathname.new(File.join(src, "thumbnails"))
        thumbsDirectory.mkpath()

        specs = ThumbnailGenerator.specs(filename, dimensions)
        ThumbnailGenerator.generate(src, thumbsDirectory, filename, specs)
      end
    end

  end

end

::Middleman::Extensions.register(:image_gallery, Middleman::ThumbnailExtension)
