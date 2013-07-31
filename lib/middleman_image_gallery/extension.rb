require "middleman-core"

module Middleman

  class ThumbnailGenerator < Extension
    def initialize(app, options_hash={}, &block)
      super

      app.after_build do |builder|
        puts '#### yeah!! ####'
      end

    end
  end

end

::Middleman::Extensions.register(:image_gallery, Middleman::ThumbnailGenerator)
