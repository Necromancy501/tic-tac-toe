require_relative('lib/board')
require_relative('lib/player')
require_relative('lib/ruleset')

board = Board.new(Ruleset.new)
puts "Player 1 (X): Please enter a name"
player_1 = Player.new(gets.chomp, 'X', board)
puts "Player 2 (O): Please enter a name"
player_2 = Player.new(gets.chomp, 'O', board)
player_arr = [player_1, player_2]

puts board

i=0
until(board.winner || board.length == 9)
  puts "#{player_arr[i%2].name} to move"
  player_arr[i%2].play_move
  i += 1
end

puts board.length==9 ? "Tie! Thanks for playing" : "#{player_arr[(i+1)%2].name} wins!"