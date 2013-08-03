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

      collectionFolder = Pathname.new(File.join(app.root, app.build_dir, app.settings.images_dir, galleryFolderName))

      collectionFolder.children.each do |galleryFolder|
        aName = galleryFolder.basename.to_s

        if galleryFolder.directory?
          # create thumbnails directory to write thumbnails
          thumbsDirectory = Pathname.new(File.join(galleryFolder, "thumbnails"))
          thumbsDirectory.mkpath() if not thumbsDirectory.exist?

          galleryFolder.children.each do |file|
            if file.file? && HelperMethods::gallery_image?(file.basename.to_s)
              dimensions = { small: '200x' }

              specs = ThumbnailGenerator.specs(file.basename().to_s, dimensions)
              ThumbnailGenerator.generate(galleryFolder.to_s, thumbsDirectory.to_s, file.basename().to_s, specs)
            end
          end
        end
      end
    end
  end

  module HelperMethods
    def self.gallery_image?(name)
      !(name =~ /\.(?:jpe?g|png|gif)$/i).nil?
    end

    def gallery_images(data, name, opts={})
      galleryFolderName = "gallery"

      src = File.join(source_dir, settings.images_dir, galleryFolderName, name)

      file_types = [:jpg, :jpeg, :png]
      glob = "#{src}/*.{#{file_types.join(',')}}"
      files = Dir[glob]

      itemsContent = ''
      files.each do |file|
        base = File.basename(file, '.*')

        caption = 'unknown'
        obj = data[name][base]
        caption = obj.caption if obj.present?

        itemsContent += make_image_tag(file.gsub(source_dir, ''), caption)
      end

      # gallery wrapping div
      content = content_tag(:div, itemsContent, class: 'gallery')

      content
    end

    private

    def make_image_tag(path, caption)

      # get thumbnail if it exists
      thumbnail = ''
      thumbnail = path if thumbnail.blank?

      # create image
      content = image_tag(thumbnail, alt: "a picture")

      # append a p tag for the caption
      caption = path if caption.blank?

      content << content_tag(:p, caption)

      # wrap link around image
      content = content_tag(:a, content, href: path)

      # wrap content up in a final wrapper div
      content = content_tag(:div, content, class: 'gallery-item')

      content
    end

  end

end

::Middleman::Extensions.register(:image_gallery, Middleman::ThumbnailExtension)


