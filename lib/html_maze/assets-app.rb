require 'tilt'
require 'valise'
require 'compass/core'

module HTMLMaze
  class AssetsApp
    def initialize(file_manager)
      @file_manager = file_manager
    end

    attr_reader :file_manager

    class AssetsContext
      def initialize(template_handler)
        @template_handler = template_handler
      end

      def render(path, locals = nil)
        template = @template_handler.find(path).contents
        if template.respond_to? :render
          template.render(self, locals)
        else
          template
        end
      end
    end

    def template_handler
      file_manager.templates("assets") do |mapping|
        case mapping
        when "sass", "scss"
          load_paths = file_manager.sub_set("assets/stylesheets").map(&:to_s)
          load_paths << ::Compass::Core.base_directory("stylesheets")
          {
            :template_cache => ::Tilt::Cache.new,
            :template_options =>
            { :load_paths => load_paths, :cache => false }}
        end
      end
    end

    def assets_context
      AssetsContext.new(template_handler)
    end

    def call(env)
      asset_path = env["PATH_INFO"]
      asset_path.sub!(/^\//,"")
      extension = asset_path.sub(/.*[.]/, ".")

      mime_type = Rack::Mime.mime_type(extension, "text/plain")
      [200, {'Content-Type' => mime_type}, [
        assets_context.render(asset_path).tap{|value|
      }
      ]]
    rescue Object => ex
      puts ex
      raise
    end
  end

  class MemoizedAssetsApp < AssetsApp
    def template_handler
      @template_handler ||= super
    end

    def assets_context
      @assets_context ||= super
    end
  end
end
