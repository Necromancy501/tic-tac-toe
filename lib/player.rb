class Player

  attr_accessor :name, :piece_symbol

  def initialize (name, piece_symbol, board)
    @name = name
    @piece_symbol = piece_symbol
    @board = board
  end

  def play_move
    puts "Please use the numpad to enter a cell: "
    @board.add_move(@piece_symbol, Integer(gets.chomp))
    @board.refresh
  end

end