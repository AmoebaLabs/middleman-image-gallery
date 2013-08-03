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
      folders = HelperMethods.gallery_folder_names(app, true)

      folders.each do |galleryFolder|
        # create thumbnails directory to write thumbnails
        thumbsDirectory = Pathname.new(File.join(galleryFolder, "thumbnails"))
        thumbsDirectory.mkpath() if not thumbsDirectory.exist?

        images = HelperMethods.images_for_gallery(app, galleryFolder.basename().to_s, true)
        images.each do |file|
          dimensions = { small: '200x' }

          specs = ThumbnailGenerator.specs(file.basename().to_s, dimensions)
          ThumbnailGenerator.generate(galleryFolder.to_s, thumbsDirectory.to_s, file.basename().to_s, specs)
        end
      end
    end
  end

  module HelperMethods
    def self.gallery_folder_names(app, build_mode=false)
      result = []
      dir = HelperMethods.gallery_dir(app, build_mode)

      dir.children.each do |item|
        if item.directory?
          result << item
        end
      end

      result
    end


    def self.gallery_dir(app, build_mode=false)
      if build_mode
        result = File.join(Application.root, app.build_dir, app.settings.images_dir)
      else
        result = File.join(app.source_dir, app.settings.images_dir)
      end

      result = File.join(result, "gallery")

      Pathname.new(result)
    end

    def self.images_for_gallery(app, name, build_mode=false)
      result = []
      dir = Pathname.new(File.join(HelperMethods.gallery_dir(app, build_mode), name))

      dir.children.each do |file|
        if file.file? && HelperMethods.gallery_image?(file.basename.to_s)
          result << file
        end
      end

      result
    end

    def self.gallery_image?(name)
      !(name =~ /\.(?:jpe?g|png|gif)$/i).nil?
    end

    def gallery_images(data, name, opts={})
      files = HelperMethods.images_for_gallery(self, name)

      itemsContent = ''
      files.each do |file|
        base = file.basename('.*')

        caption = 'unknown'
        obj = data[name][base]
        caption = obj.caption if obj.present?

        itemsContent += make_image_tag(file, caption)
      end

      # gallery wrapping div
      content = content_tag(:div, itemsContent, class: 'gallery')

      content
    end

    private

    def make_image_tag(file, caption)
      path = file.to_s.gsub(source_dir, '')

      # get thumbnail if it exists

      thumbnameFile = Pathname.new(File.join(file.parent, 'thumbnails', file.basename))
      thumbnailPath = ''
      thumbnailPath = thumbnameFile.to_s.gsub(source_dir, '') if thumbnameFile.exist?

      thumbnailPath = path if thumbnailPath.blank?

      puts "file: #{thumbnameFile}"
      puts "path: #{thumbnailPath}"


      # create image
      content = image_tag(thumbnailPath, alt: "a picture")

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


