module Middleman

  # =========================================================
  # =========================================================

  class ThumbnailWriter
    def initialize(app)
      @app = app
      @gallery = GalleryDirectoryHelper.new(app)
    end

    def write
      createThumbnails
    end

    private

    def createThumbnails()
      folders = @gallery.directories(true)

      folders.each do |galleryFolder|
        # create thumbnails directory to write thumbnails
        thumbsDirectory = Pathname.new(File.join(galleryFolder, "thumbnails"))
        thumbsDirectory.mkpath() if not thumbsDirectory.exist?

        images = @gallery.images(galleryFolder.basename().to_s, true)
        images.each do |file|
          dimensions = { small: '200x' }

          specs = ThumbnailGenerator.specs(file.basename().to_s, dimensions)
          ThumbnailGenerator.generate(galleryFolder.to_s, thumbsDirectory.to_s, file.basename().to_s, specs)
        end
      end
    end

  end

  # =========================================================
  # =========================================================

  class GalleryGenerator
    def initialize(app)
      @app = app
      @gallery = GalleryDirectoryHelper.new(app)
    end

    def gen(data, name, opts)
      files = @gallery.images(name)

      itemsContent = ''
      files.each do |file|
        base = file.basename('.*').to_s

        caption = 'unknown'
        obj = data[name][base]
        caption = obj.caption if obj.present?

        itemsContent += make_image_tag(file, caption)
      end

      # gallery wrapping div
      content = @app.content_tag(:div, itemsContent, class: 'gallery')

      content
    end

    private

    def make_image_tag(file, caption)
      path = file.to_s.gsub(@app.source_dir, '')

      # get thumbnail if it exists

      thumbnameFile = Pathname.new(File.join(file.parent, 'thumbnails', file.basename))
      thumbnailPath = ''
      thumbnailPath = thumbnameFile.to_s.gsub(@app.source_dir, '') if thumbnameFile.exist?

      image_options = {alt: "img alt text"}
      if thumbnailPath.blank?
        thumbnailPath = path
        image_options[:width] = "200"
      end

      # create image
      content = @app.image_tag(thumbnailPath, image_options)

      # wrap link around image
      content = @app.content_tag(:a, content, href: path)

      # append a p tag for the caption
      caption = path if caption.blank?

      content << @app.content_tag(:p, caption)

      # wrap content up in a final wrapper div
      content = @app.content_tag(:div, content, class: 'gallery-item')

      content
    end

  end

  # =========================================================
  # =========================================================

  class GalleryDirectoryHelper
    def initialize(app)
      @app = app
    end

    def directories(build_mode=false)
      result = []
      dir = directory(build_mode)

      dir.children.each do |item|
        if item.directory?
          result << item
        end
      end

      result
    end

    def directory(build_mode=false)
      if build_mode
        result = File.join(Application.root, @app.build_dir, @app.settings.images_dir)
      else
        result = File.join(@app.source_dir, @app.settings.images_dir)
      end

      result = File.join(result, "gallery")

      Pathname.new(result)
    end

    def images(name, build_mode=false)
      result = []
      dir = Pathname.new(File.join(directory(build_mode), name))

      dir.children.each do |file|
        if file.file? && gallery_image?(file.basename.to_s)
          result << file
        end
      end

      result
    end

    # ============
    # Private
    # ============

    def gallery_image?(name)
      !(name =~ /\.(?:jpe?g|png|gif)$/i).nil?
    end

  end

end


