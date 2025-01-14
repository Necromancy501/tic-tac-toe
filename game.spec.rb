require_relative 'game'
require 'stringio'
require 'tempfile'

RSpec.describe Ruleset, '#group_moves' do

  subject(:ruleset) { described_class.new }

  context 'when given an array of moves' do

    it 'groups them based on symbol' do
      moves_arr = [ ['X', 3] , ['O', 4] ,['X', 2], ['O',7]]
      result = ruleset.group_moves(moves_arr)
      expect(result).to eql({ 'X' => [3, 2] , 'O' => [4, 7] })
    end
  end
end

RSpec.describe Ruleset, '#symbol_winner' do

  subject(:ruleset) { described_class.new }

  context 'when there is a winner' do

    it 'returns the symbol of the winner' do
      moves_arr = [ ['X', 3] , ['O', 4] ,['X', 2], ['O',7], ['X', 5],['O', 1]]
      moves_hash = ruleset.group_moves(moves_arr)
      result = ruleset.symbol_winner moves_hash
      expect(result).to eql('O')
    end
    
  end

  context 'when there is no winner' do

    it 'returns false' do
      moves_arr = [ ['X', 3] , ['O', 4] ,['X', 2], ['O',7], ['X', 5] ]
      moves_hash = ruleset.group_moves(moves_arr)
      result = ruleset.symbol_winner moves_hash
      expect(result).to eql(false)
    end
    
  end

end

RSpec.describe Player, '#play_move' do

  subject(:player) { described_class.new 'Jhon Doe', 'X', board }
  let(:board) { instance_double(Board) }

  context 'when entering a valid move' do

    before do
      allow(player).to receive(:gets).and_return('5') # Simulate user input

      board_state = [ ['X', 3] , ['O', 4] ,['X', 2], ['O',7]]
      allow(board).to receive(:board).and_return(board_state) # Stub board


      allow(board).to receive(:add_move) # Stub add_move
      allow(board).to receive(:refresh) # Stub refresh
    end

    it 'calls #add_move once' do

      # Suppress output during the test
      expect {
        original_stdout = $stdout
        $stdout = StringIO.new
        player.play_move
        $stdout = original_stdout
      }.to_not raise_error

      expect(board).to have_received(:add_move).with('X', 5) # Verify add_move was called
    end
  end
end

RSpec.describe Board, '#add_move' do

  subject(:board) { described_class.new rules }
  let(:rules) { instance_double(Ruleset) }

  context 'when entering a valid move' do

    before do
      board_state = [['X', 3], ['O', 4], ['X', 2], ['O', 7]]
      board.board = board_state
    end

    it 'adds the move to board' do
      expect { board.add_move('X', 6) }.to change { board.board.length }.by(1)
      expect(board.board).to include(['X', 6])
    end
  end
end

RSpec.describe Board, '#add_to_display' do

  subject(:board) { described_class.new rules }
  let(:rules) { instance_double(Ruleset) }

  context 'when number is a move' do

    before do
      board_state = [['X', 3], ['O', 4], ['X', 2], ['O', 7]]
      board.board = board_state
    end

    it 'adds brackets to symbol' do
      result = board.add_to_display 3
      expect(result).to eql('[X]')
    end

  end

  context 'when number is not a move' do

    before do
      board_state = [['X', 3], ['O', 4], ['X', 2], ['O', 7]]
      board.board = board_state
    end

    it 'returns empty brackets' do
      result = board.add_to_display 1
      expect(result).to eql('[ ]')
    end

  end

end

RSpec.describe Board, '#refresh' do

  subject(:board) { described_class.new rules }
  let(:rules) { instance_double(Ruleset) }

  context 'when having a valid board state' do

    before do
      board_state = [['X', 3], ['O', 4], ['X', 2], ['O', 7]]
      board.board = board_state
    end

    it 'prints the board on console' do
      expect { board.refresh }.to output(
        "\n[O][ ][ ]\n[O][ ][ ]\n[ ][X][X]\n\n"
      ).to_stdout
    end
  end
end

RSpec.describe Board, '#winner' do
  subject(:board) { described_class.new rules }
  let(:rules) { instance_double(Ruleset) }

  context 'when having a winner board state' do
    before do
      board_state = [['X', 3], ['O', 4], ['X', 2], ['O', 7], ['X', 5], ['O', 1]]
      board.board = board_state

      # Stub the methods to simulate the behavior
      allow(rules).to receive(:group_moves).with(board_state).and_return({
        'X' => [3, 2, 5],
        'O' => [4, 7, 1]
      })
      allow(rules).to receive(:symbol_winner).with({
        'X' => [3, 2, 5],
        'O' => [4, 7, 1]
      }).and_return('O')
    end

    it 'returns the winning symbol' do
      result = board.winner
      expect(result).to eql('O') # Assert the expected winner
    end
  end

  context 'when there is no winner' do
    before do
      board_state = [['X', 3], ['O', 4], ['X', 2], ['O', 7]]
      board.board = board_state

      # Stub the methods to simulate the behavior
      allow(rules).to receive(:group_moves).with(board_state).and_return({
        'X' => [3, 2],
        'O' => [4, 7]
      })
      allow(rules).to receive(:symbol_winner).with({
        'X' => [3, 2],
        'O' => [4, 7]
      }).and_return(false)
    end

    it 'returns false' do
      result = board.winner
      expect(result).to eql(false) # Assert no winner
    end
  end
end

RSpec.describe Board, '#length' do

  subject(:board) { described_class.new rules }
  let(:rules) { instance_double(Ruleset) }

  context 'when having a valid board state' do

    before do
      board_state = [['X', 3], ['O', 4], ['X', 2], ['O', 7]]
      board.board = board_state
    end

    it 'returns board length' do
      result = board.length
      expect(result).to eql(4)
    end
  end
end

RSpec.describe 'Game script' do
  let(:game_script) { 'game.rb' }

  def run_script_with_input(*inputs)
    # Create a temporary file with the simulated inputs
    input_file = Tempfile.new('game_input')
    input_file.write(inputs.join("\n"))
    input_file.rewind

    # Redirect stdout to suppress console output
    output = nil
    original_stdout = $stdout
    $stdout = StringIO.new

    begin
      # Use the temporary file as the script's input
      output = `ruby #{game_script} < #{input_file.path}`
    ensure
      # Restore stdout and cleanup
      $stdout = original_stdout
      input_file.close
      input_file.unlink
    end

    output
  end

  it 'plays a game to completion and declares a winner' do
    # Simulate user inputs for names and moves
    output = run_script_with_input('Alice', 'Bob', '5', '1', '9', '2', '7', '3', '8', '4', '6')
    output_lines = output.split("\n")

    # Validate the output includes the names and moves
    expect(output_lines).to include('Player 1 (X): Please enter a name')
    expect(output_lines).to include('Player 2 (O): Please enter a name')
    expect(output_lines).to include('Alice to move')
    expect(output_lines).to include('Bob to move')

    # Validate the game ends with a win
    expect(output_lines).to include('Bob wins!')
  end

  it 'handles a tie game correctly' do
    # Simulate user inputs for names and a tie game
    output = run_script_with_input('Alice', 'Bob', '1', '9', '4', '6', '5', '2', '8', '7', '3')
    output_lines = output.split("\n")

    # Validate the game ends in a tie
    expect(output_lines).to include('Tie! Thanks for playing')
  end
end