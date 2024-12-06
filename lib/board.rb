class Board

  attr_accessor :board, :rules

  def initialize(rules)
    @board = []
    @rules = rules
  end

  def add_move(symbol, keypad_input)
    @board.push [symbol, keypad_input]
  end

  def to_s
    refresh
  end

  def add_to_display(index)
    arr_flat = @board.flatten
    if arr_flat.include?(index)
      "[#{arr_flat[arr_flat.find_index(index)-1]}]"
    else
      "[ ]"
    end
  end

  def refresh
    board_display = "\n"
    i = 9
    3.times do
      row_cells = []
      3.times do
        row_cells << add_to_display(i)
        i -= 1
      end
      board_display += row_cells.reverse.join + "\n"
    end
    board_display += "\n"
    puts board_display
  end

  def winner
    rules.symbol_winner(rules.group_moves(@board))
  end

  def length
    @board.length
  end

end