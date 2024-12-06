class Player

  attr_accessor :name, :piece_symbol

  def initialize (name, piece_symbol, board)
    @name = name
    @piece_symbol = piece_symbol
    @board = board
  end

  def play_move
    puts "Please use the numpad to enter a cell: "
    while move = Integer(gets.chomp)
      unless @board.board.flatten.include?(move)
          @board.add_move(@piece_symbol, move)
          @board.refresh
          break
      end
      puts "Move already made. Please try again:"
    end
  end
end