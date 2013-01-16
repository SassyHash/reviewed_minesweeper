require 'debugger'

class Minesweeper

  attr_reader :gameboard

  DELTAS = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]

  def initialize
  end

  def user_settings
    puts "Minesweeper grid size? 1 for 9x9, 2 for 16x16"
    size = gets.chomp.to_i
    unless size == 1 || size == 2
      puts "invalid entry"
      user_settings #BY I'm sure you remember but Ned discouraged recursive loop for error 
    end
    size
  end

  def play
    build_gameboard(user_settings)
    while game_over == false #or while !game_over
      print_board
      player_move = move
      check_coordinate(player_move)
    end
    "GAME"
  end

  def game_over #should be game_over? 
    false
  end

  # gameboard methods
  def build_gameboard(size)
    n, m = 0
    n, m = 9, 10 if size == 1 #I like that user can change game board size
    n, m = 16, 40 if size == 2
    @gameboard = Array.new(n) do
      Array.new(n) { Square.new } #I like that you pulled tile as its own class
    end
    #debugger
    set_bomb(m)
    fringe_sq_iterator
  end

  def set_bomb(bomb_count)
    bombs = 0
    while true
      return if bombs == bomb_count #or unless bomb == bomb_count
      row = @gameboard.sample #this is a cool method!
      square = row.sample
      if square.bomb == false
        square.bomb = true
        bombs += 1
      end
    end
  end

  def print_board
    @gameboard.each do |row|
      row.each do |square|
        if square.revealed == true || square.flagged == true
          if square.flagged == true
            print "F"
            next
          elsif square.bomb == true
            print "X"
            next
          elsif square.adj_bomb == 0
            print " "
          else
            print "#{square.adj_bomb}"
          end
        else
          print "*"
        end
      end
      print "\n"
    end
  end

  def fringe_sq_iterator #unclear name for a method
    @gameboard.each_with_index do |row, i|
      row.each_with_index do |square, j|
        if square.bomb == true #if square.bomb
          adjacents = adjacent_squares([i, j]) 
          adjacents.each do |coordinates|
            @gameboard[coordinates[0]][coordinates[1]].adj_bomb += 1
          end
        end
      end
    end
  end

  def adjacent_squares(coordinates)
    adjacents = DELTAS.map do |coord|
      x = coord[0] + coordinates[0]
      y = coord[1] + coordinates[1]
      [x, y]
    end
    selected = adjacents.select do |coord| #instead of selecting those that meet the categories you could check in the mapping
      coord[0] < @gameboard.length && coord[0] > 0 && coord[1] < @gameboard.length && coord[1] > 0
    end
    selected
  end

  # user methods

  def move
    puts "Type 'R' and your coordinates to reveal (ex: R 4 5)" #probably made life easier for you guys to do numbers on x and y cord!
    puts "Type 'F' and your coordinates to flag (ex: F 4 5)"
    move = gets.chomp.split(' ')
    [move[0].downcase, [move[1].to_i, move[2].to_i]]
  end

  def check_coordinate(move)
    type = move[0]
    coord = move[1]
    if type == 'r'
      if @gameboard[coord[0]][coord[1]].bomb == true
        @gameboard[coord[0]][coord[1]].revealed = true
        game_over = true
      else
        reveal(coord)
      end
    elsif type == 'f' #could just be else
      @gameboard[coord[0]][coord[1]].flagged = true
    end
  end

  def reveal(move)
    #debugger
    queue = [move]
    checked = []

    while move = queue.shift #we did this recursively, but this makes sense. 
      @gameboard[move[0]][move[1]].revealed = true
      checked << move
      to_check = adjacent_squares(move)
      to_check.each do |coord|
        if @gameboard[coord[0]][coord[1]].bomb == false || !checked.include?(coord)
          queue << coord
        end
      end
      p queue
    end
  end
end

class Square

  attr_accessor :bomb, :adj_bomb, :flagged, :revealed

  def initialize
    @bomb = false
    @adj_bomb = 0
    @flagged = false
    @revealed = false
  end

end
