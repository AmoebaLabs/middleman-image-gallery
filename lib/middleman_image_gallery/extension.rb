require "middleman-core"

class ThumbnailGenerator < Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super

    app.after_build do |builder|
      puts '#### yeah!! ####'
    end

  end

  alias :included :registered
end

::Middleman::Extensions.register(:image_gallery, ThumbnailGenerator)
