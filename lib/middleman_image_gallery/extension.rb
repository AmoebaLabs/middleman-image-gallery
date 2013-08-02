require "middleman-core"
require 'middleman_image_gallery/thumbnail_generator'

module Middleman

  class ThumbnailExtension < Extension
    def initialize(app, options_hash={}, &block)
      super

      # append helper methods
      app.helpers Middleman::HelperMethods

      # after build callback
      app.after_build do |builder|
        ThumbnailExtension.createThumbnails(self)
      end

      # after configuration callback
      app.after_configuration do
      end
    end

    private

    def self.createThumbnails(app)
      galleryFolderName = "gallery"

      src = Pathname.new(File.join(app.source_dir, app.settings.images_dir, galleryFolderName))

      file_types = [:jpg, :jpeg, :png]

      glob = "#{src}/*.{#{file_types.join(',')}}"
      files = Dir[glob]

      files.each do |file|
        filename = File.basename(file)

        dimensions = { small: '200x' }

        thumbsDirectory = Pathname.new(File.join(app.root, app.settings.build_dir, app.settings.images_dir, galleryFolderName, "thumbnails"))
        thumbsDirectory.mkpath()

        specs = ThumbnailGenerator.specs(filename, dimensions)
        ThumbnailGenerator.generate(src, thumbsDirectory, filename, specs)
      end
    end

  end

  module HelperMethods
    def gallery_images(data, name, opts={})
      result = ''
      galleryFolderName = "gallery"

      src = File.join(source_dir, settings.images_dir, galleryFolderName, name)

      file_types = [:jpg, :jpeg, :png]
      glob = "#{src}/*.{#{file_types.join(',')}}"
      files = Dir[glob]

      files.each do |file|
        base = File.basename(file, '.*')

        caption = 'unknown'
        obj = data[name][base]
        caption = obj.caption if obj.present?

        result += make_image_tag(file.gsub(source_dir, ''), caption)
      end

      result.html_safe
    end

    private

    def make_image_tag(path, caption)
      # create image
      content = image_tag(path, alt: "a picture")

      # append a p tag for the caption
      caption = '(nothing)' if caption.blank?

      content << content_tag(:p, caption)

      # wrap link around image
      content = content_tag(:a, content, href: 'http://www.padrinorb.com')

      # wrap content up in a final wrapper div
      content = content_tag(:div, content, class: 'gallery-item')

      content
    end

  end

end

::Middleman::Extensions.register(:image_gallery, Middleman::ThumbnailExtension)


