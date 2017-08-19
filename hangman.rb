require 'json'

class Game
# initialize the program with the choice to load or play a game
  def initialize
    puts "Welcome to hangaman ruby game! Choose what to do:\n1. New Game\n2. Load Game"
    loop do
      case gets.chomp.to_i
      when 1
        reset
        play
        break
      when 2
        load_game
        play
        break
      else
        puts "Choose 1 or 2, please:"
      end
    end
  end

# load the list of word from the file, select the word between 5 & 12 chars
# choose one word randomly from the array with sample
  def get_word
    words = File.readlines('5desk.txt')
    words.each { |word| word.chomp! }
    words_list = words.select { |word| word.length.between?(5, 12)}

    words_list.sample.downcase.split("")
  end

# reset all the instance variables
  def reset
    @guessed = []
    @to_guess = get_word
    @guessing = Array.new(@to_guess.length, "_")
    @lives = 10
  end

# get the choice of the player
  def get_guess
    print "\nGuess (or type 'save' to save and quit, or 'exit' to quit!): > "
    guess = gets.chomp.to_s.downcase
    if guess == "save"
      save_game
    elsif guess == "exit"
      exit
    elsif guess.length > 1 || !guess.between?('a', 'z')
      puts "Insert only one letter please"
      return false
    elsif @guessed.include?(guess)
      puts "Already guessed!"
      return false
    else
      return guess
    end
  end

# check if the letter is in the word to guess
  def check(guess)
    @guessed << guess
    if !@to_guess.index(guess).nil?
      @guessing[@to_guess.index(guess)] = guess
    else
      @lives -= 1
    end
  end

# play again method
  def play_again
    puts "Play again? (y/n)"
    return false unless gets.chomp.downcase == "y"
    reset
    true
  end

# get the name for the file to create, check if exist, or create a new directory
# create the file, write it with serialize, and exit
  def save_game
    puts "Enter a name to save the game:"
    save_name = gets.chomp

    Dir.mkdir("games") unless Dir.exists? "games"
    filename = "games/#{save_name}"

    if File.file?(filename)
      puts "Name alreasy chosen!"
      save_game
    else
      File.open(filename, 'w') {|save| save.write(serialize)}
      puts "Game saved!"
      exit
    end
  end

# load the directory in an array to check if there are saved games. If yes print
# a list of all the file, and get the choice from the user to load the JSON and
# set the instance variables for the game
  def load_game
    saved_games = Dir["games/*"]
    if saved_games.empty?
      puts "No saved games"
      exit
    end
    saved_games.each_with_index do |file, n|
      time = File.mtime(file).strftime("%Y-%m-%d %H:%M")
      puts "#{n+1}. #{file[6..-1]} created: #{time}"
    end

    loop do
      puts "Enter a number to open the game:"
      choice = gets.chomp.to_i
      if choice.between?(1, saved_games.length)
        JSON.load(File.open(saved_games[choice - 1], 'r').read).each do |var, val|
          self.instance_variable_set '@'+var,val
        end
        break
      end
    end
  end

# serialize the instance variables for JSON
  def serialize
    {"to_guess" => @to_guess,
    "guessed" => @guessed,
    "lives" => @lives,
    "guessing" => @guessing}.to_json
  end

# print the status of the game, the number of lives left and the letter chosen
# check the guess, if there are lives left, if the player won and play again.
  def play
    loop do
      while true
        puts "#{@guessing.join(' ')}"
        puts "Lives left: #{@lives} | Guessed: #{@guessed.join(', ')}"
        guess = get_guess
        if guess
          check(guess)
        end
        if @lives < 1
          puts "No lives left! You lost! The word was: \"#{@to_guess.join}\""
          break
        end
        if @guessing.join == @to_guess.join
          puts "#{@guessing.join} was the word. You won!!"
          break
        end
      end
      break unless play_again
    end
  end


end

Game.new
