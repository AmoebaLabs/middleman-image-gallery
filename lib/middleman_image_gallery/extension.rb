require "middleman-core"

module Middleman

  class ThumbnailGenerator < Extension
    def initialize(app, options_hash={}, &block)
      super

      #app.after_build do |builder|
      #  puts '#### yeah!! ####'
      #end
      #

      dimensions = options[:dimensions]
      namespace = options[:namespace_directory].join(',')

      dir = Pathname.new(File.join(source_dir, images_dir))

      app.after_build do |builder|

        puts 'building...'

        file_types = [:jpg, :jpeg, :png]

        glob = "#{dir}/#{namespace}/*.{#{file_types.join(',')}}"
        files = Dir[glob]

        files.each do |file|
          path = file.gsub(source_dir, '')

          puts path

        end
      end


    end
  end

end

::Middleman::Extensions.register(:image_gallery, Middleman::ThumbnailGenerator)
