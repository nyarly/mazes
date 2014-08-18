module HTMLMaze
  class WebApp
    def initialize(maze)
      @maze = maze
    end
    attr_reader :maze

    def call(env)
      x=5
      y=6
      dir=:north

      begin
        q_hash = Rack::Utils.parse_query(env["QUERY_STRING"])
        x = Integer(q_hash["x"])
        y = Integer(q_hash["y"])
        dir = DIR_S.fetch(q_hash["dir"])
      rescue => ex
        return [404, {'Content-Type' => 'text/html'}, [
          "Hm: #{ex}\n",
          "#{q_hash.inspect rescue "???"}\n",
          "Try ?x=5&y=5&dir=north"
        ]]
      end

      [200, {'Content-Type' => 'text/html'}, [
        maze_html(x, y, dir)
      ]]
    end

    DIRS = [:north,:east,:south,:west]

    DIR_S = Hash[ DIRS.map(&:to_s).zip(DIRS) ]
    DIR_CHAR = Hash[ DIRS.zip(%w{^ > v <}) ]

    LEFT_OF = Hash[ DIRS.zip(DIRS.rotate(-1)) ]
    RIGHT_OF = Hash[ DIRS.zip(DIRS.rotate(1)) ]

    def cell_wall_li(from, facing, cell, wall)
      if cell.wall?(wall)
        "<li class='wall #{wall}'></li>"
      else
        "<ul class='open #{wall}'>
          #{cell_li(from, cell.move(wall), facing)}
        </ul>"
      end
    end

    def cell_li(from, cell, facing)
      [].tap do |list|
        [LEFT_OF[facing], facing, RIGHT_OF[facing]].each do |dir|
          unless MOVES[dir].towards?(cell, from)
            list << cell_wall_li(from, facing, cell, dir)
          end
        end
      end.join("\n")
    end

    def turn_left_link(x,y,dir)
      "x=#{x}&y=#{y}&dir=#{LEFT_OF[dir]}"
    end

    def turn_right_link(x,y,dir)
      "x=#{x}&y=#{y}&dir=#{RIGHT_OF[dir]}"
    end

    def move_forward_link(x,y,dir)
      case dir
      when :north
        "x=#{x}&y=#{y-1}&dir=#{dir}"
      when :south
        "x=#{x}&y=#{y+1}&dir=#{dir}"
      when :east
        "x=#{x+1}&y=#{y}&dir=#{dir}"
      when :west
        "x=#{x-1}&y=#{y}&dir=#{dir}"
      end
    end

    def move_backward_link(x,y,dir)
      case dir
      when :north
        "x=#{x}&y=#{y+1}&dir=#{dir}"
      when :south
        "x=#{x}&y=#{y-1}&dir=#{dir}"
      when :east
        "x=#{x-1}&y=#{y}&dir=#{dir}"
      when :west
        "x=#{x+1}&y=#{y}&dir=#{dir}"
      end
    end

    def nav_link_list(x,y,dir)
      "<ul class='nav'>
      <li><a id='turn-left' href='?#{turn_left_link(x,y,dir)}'>Turn Left</a></li>
      <li><a id='move-forward' href='?#{move_forward_link(x,y,dir)}'>Move Forward</a></li>
      <li><a id='move-backward' href='?#{move_backward_link(x,y,dir)}'>Move Backward</a></li>
      <li><a id='turn-right' href='?#{turn_right_link(x,y,dir)}'>Turn Right</a></li>
      </ul>"
    end

    def maze_html(x,y,dir)
      HTMLMaze::Formatter.new(maze).render(x,y,DIR_CHAR[dir])
      cell = Cell.new(maze,x,y)
"<html><head>
  <link href='assets/maze.css' rel='stylesheet' type='text/css' />
</head><body>
  <script type='text/javascript' src='assets/keyboard.js'> </script>
  <div class='view'>
  #{cell_wall_li(cell, dir, cell, dir).tap{|value| puts "#{__FILE__}:#{__LINE__} => \n#{value}"}}
  </div>
  <ul>
  #{nav_link_list(x,y,dir)}
</body></html>"
    end
  end
end
