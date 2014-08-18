require 'rack'
require 'thin'
require 'html_maze/web_app'
require 'html_maze/assets-app'
require 'html_maze/mazes'

module HTMLMaze
  class CLI
    def builder(maze)
      Rack::Builder.new do
        map "/assets" do
          run MemoizedAssetsApp.new(Valise::define{ ro "."})
        end

        run WebApp.new(maze)
      end
    end

    def initialize(_argv)

    end

    def start
      maze = Maze.new(15,15)
      BacktrackingDigger.dig(maze)

      HTMLMaze::Formatter.new(maze).render
      Thin::Logging.debug = :log
      server = Thin::Server.new(builder(maze).to_app, 8765)
      server.start
    end
  end
end
