class Ruleset

  def group_moves(board_arr)
    board_arr.reduce(Hash.new { |hash, key| hash[key] = [] }) do |result, pair|
      result[pair[0]] << pair[1]
      result
    end
  end
  
  def symbol_winner(board_hash)
    board_hash.each do |symbol, moves|
      moves.each do |move_start|
        (moves-[move_start]).each do |move_middle|
          move_end = 2*move_middle - move_start
          if moves.include?(move_end)
            if(move_start%3 == move_middle%3) && (move_middle%3 == move_end%3)
              return symbol
            elsif((move_start%3 == 1) && (move_middle%3 == 2) && (move_end%3 == 0))
              return symbol
            elsif((move_start%3 == 0) && (move_middle%3 == 2) && (move_end%3 == 1))
              return symbol
            end   
          end
        end
      end
    end
    false
  end
end