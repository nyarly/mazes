module HTMLMaze
  class Maze
    def initialize(wide, high)
      @wide, @high = wide, high

      @cells = Array.new(wide) do
        Array.new(high){ empty_cell }
      end

      @rights = Array.new(wide + 1) do
        Array.new(high){ blank_wall }
      end

      @downs = Array.new(wide) do
        Array.new(high + 1){ blank_wall }
      end
    end

    attr_reader :cells, :downs, :rights, :wide, :high

    def empty_cell
      0
    end

    def bread_crumb
      1
    end

    def blank_wall
      0
    end

    def connection
      1
    end
  end

  class Move
    def initialize(dx, dy)
      @dx, @dy = dx, dy
    end

    def from(cell)
      Cell.new(cell.maze, cell.x + @dx, cell.y + @dy)
    end

    def towards?(start, to) #will this move reduce the distance
      start.distance(to) >= from(start).distance(to)
    end
  end

  class DownSide
    def initialize(dx)
      @dx = dx
    end

    def at(cell)
      cell.maze.downs[cell.x][cell.y + @dx]
    end

    def set(cell, value)
      cell.maze.downs[cell.x][cell.y + @dx] = value
    end

    def wall?(cell)
      at(cell) == cell.maze.blank_wall
    end

    def string_for(cell)
      case at(cell)
      when cell.maze.blank_wall
        "-"
      else
        " "
      end
    end
  end

  class RightSide < DownSide
    def at(cell)
      cell.maze.rights[cell.x + @dx][cell.y]
    end

    def set(cell, value)
      cell.maze.rights[cell.x + @dx][cell.y] = value
    end

    def string_for(cell)
      case at(cell)
      when cell.maze.blank_wall
        "|"
      else
        " "
      end
    end
  end

  Compass = {
    :move_north => Move.new(0, -1),
    :move_south => Move.new(0,  1),
    :move_east  => Move.new( 1, 0),
    :move_west  => Move.new(-1, 0),

    :north_wall => DownSide.new(0),
    :south_wall => DownSide.new(1),
    :west_wall => RightSide.new(0),
    :east_wall => RightSide.new(1)
  }

  WALLS = {
    :north => DownSide.new(0),
    :south => DownSide.new(1),
    :west => RightSide.new(0),
    :east => RightSide.new(1)
  }

  MOVES = {
    :north => Move.new(0, -1),
    :south => Move.new(0,  1),
    :east  => Move.new( 1, 0),
    :west  => Move.new(-1, 0),
    }

  class Cell
    def initialize(maze, x, y)
      @maze = maze
      @x = x
      @y = y
    end
    attr_accessor :x, :y, :maze

    def inspect
      "<#{self.class}:#{"%0x" % self.object_id}: "+
      "x:#@x y:#@y " +
      "N:#{Compass[:north_wall].at(self).inspect rescue "?"} "+
      "E:#{Compass[:east_wall].at(self).inspect rescue "?"} "+
      "S:#{Compass[:south_wall].at(self).inspect rescue "?"} "+
      "W:#{Compass[:west_wall].at(self).inspect rescue "?"}>"
    end

    def wall?(dir)
      WALLS[dir].wall?(self)
    end

    def move(dir)
      MOVES[dir].from(self)
    end

    def here
      maze.cells[x][y]
    end

    def set(value)
      maze.cells[x][y] = value
    end

    def distance(to)
      (x - to.x).abs + (y - to.y).abs
    end
  end

  class BacktrackingDigger
    def self.dig(maze)
      new(maze).dig!
    end

    def initialize(maze)
      @maze = maze
      @visited = Hash.new do |h,k|
        h[k] = {}
      end
    end
    attr_reader :maze

    def options
      [
        [:north, Compass[:north_wall], Compass[:move_north]],
        [:east,  Compass[:east_wall],  Compass[:move_east]],
        [:south, Compass[:south_wall], Compass[:move_south]],
        [:west,  Compass[:west_wall],  Compass[:move_west]]
      ]
    end

    def visit(cell)
      @visited[cell.x][cell.y] = true
    end

    def visited?(cell)
      @visited[cell.x][cell.y]
    end

    def legit?(cell)
      return false unless (0...maze.wide).include?(cell.x)
      return false unless (0...maze.high).include?(cell.y)
      return (not visited?(cell))
    end

    def dig!
      x = rand(maze.wide)
      y = rand(maze.high)

      dig = [ Cell.new(maze, x, y) ]

      count = 1000

      until dig.empty? or count <= 0
        count -= 1
        neighbors = options.map do |dir, wall, move|
          [dir, wall, move, move.from(dig.last)]
        end.select{|dir, wall, move, cell| legit?(cell)}

        neighbor =
          case neighbors.length
          when 0
            dig.pop
            next
          when 1
            neighbors.first
          else
            neighbors[rand(neighbors.length)]
          end

        neighbor[1].set(dig.last, maze.connection)
        visit(neighbor[3])
        dig.push(neighbor[3])
      end
    end
  end

  class Formatter
    def initialize(maze)
      @maze = maze
    end

    def render(at_x=nil, at_y=nil, spot_char=nil)
      cell = Cell.new(@maze, 0, 0)

      (0...@maze.high).each do |y|
        cell.y = y
        (0...@maze.wide).each do |x|
          cell.x = x
          print "+"
          print Compass[:north_wall].string_for(cell)
        end
        puts "+"

        (0...@maze.wide).each do |x|
          cell.x = x
          print Compass[:west_wall].string_for(cell)
          if cell.x == at_x and cell.y == at_y
            print spot_char || "x"
          else
            print cell.here == @maze.bread_crumb ? "." : " "
          end
        end
        puts Compass[:east_wall].string_for(cell)
      end

      (0...@maze.wide).each do |x|
        cell.x = x
        print "+"
        print Compass[:south_wall].string_for(cell)
      end
      puts "+"
    end
  end
end

if __FILE__ == $0
  maze = HTMLMaze::Maze.new(15,15)
  HTMLMaze::BacktrackingDigger.dig(maze)
  HTMLMaze::Formatter.new(maze).render
  p HTMLMaze::Cell.new(maze,4,4)
end
