require 'json'

# open file in read
file = File.open("google-10000-english-no-swears.txt", "r")

word_bank = []

alphabet = ("a".."z").to_a

game_over = false

contents = file.read.split

#create word bank with words between 5 and 12 letters long
contents.each do |word|
  if word.length >= 5 && word.length <= 12
    word_bank << word
  end
  
end

class WordBank
  def initialize(words)
    @words = words
  end

  def select_random_word
    @words.sample
  end
end

class Word
  def initialize(word_bank)
    @word_bank = word_bank
    @selected_word = @word_bank.select_random_word
    @displayed_word = "_" * @selected_word.length
  end

  def length
    @selected_word.length
  end

  def include?(letter)
    @selected_word.include?(letter)
  end

  def split
    @selected_word.split("")
  end

  def display_word
    @displayed_word
  end

  def to_s
    @selected_word
  end

  def update_displayed_word(letter)
    found = false
    @selected_word.split("").each_with_index do |char, index|
      if char == letter
        @displayed_word[index] = letter
        found = true
      end
    end
    found
  end
end

class Game
  def initialize(secret_word)
    @secret_word = Word.new(secret_word)
    @display = Array.new(@secret_word.length, "_ ")
    @letters_guessed = []
    @hangman = Hangman.new
    @game_over = false
    @errors = 0
  end

  def start
    puts "Let\'s play Hangman!"
    puts "The secret word has #{@secret_word} letters."

    until @game_over do
      display_game_state
      letter = get_user_input
      update_game_state(letter)
    end

    puts "Game over. The secret word was #{@secret_word}."
  end

  private

  def display_game_state
    @hangman.draw(@errors)
    puts "Letters guessed: #{@letters_guessed}"
    puts "Secret word: #{@display}"
  end

  def get_user_input
    loop do
      puts "Guess a letter:"
      letter = gets.chomp.downcase
      if letter.match?(/[a-z]/) && !@letters_guessed.include?(letter) && letter.length == 1
        return letter
      else
        puts "Invalid input. Please guess a letter from A to Z that you have not already guessed."
      end
    end
  end

  def update_game_state(letter)
    if @letters_guessed.include?(letter)
      puts "This letter has already been guessed."
    elsif @secret_word.include?(letter)
      if @secret_word.update_displayed_word(letter)
        puts "Good guess!"
      end
    else
      puts "Bad guess!"
      @hangman.draw(@errors += 1)
    end
  
    @letters_guessed << letter
  
    @display = @secret_word.display_word.split("").join(" ")
  
    if !@display.include?("_")
      @game_over = true
      puts "Congratulations! You guessed the secret word: #{@secret_word}."
    elsif @errors == 6
      @game_over = true
      puts "Game over. The secret word was #{@secret_word}."
    end
  end

  def save_game(filename)
    game_state = {
      secret_word: @secret_word.to_s,
      displayed_word: @secret_word.display_word,
      letters_guessed: @letters_guessed,
      errors: @errors
      # Add any other properties you want to save here
    }
    File.write(filename, game_state.to_json)
    puts "Game saved to #{filename}."
  end

  def self.load_game(filename)
    game_state = JSON.parse(File.read(filename))
    secret_word = game_state['secret_word']
    letters_guessed = game_state['letters_guessed']
    errors = game_state['errors']
    # Initialize a new game with the saved state
    game = Game.new(secret_word)
    game.instance_variable_set('@display', game_state['displayed_word'])
    game.instance_variable_set('@letters_guessed', letters_guessed)
    game.instance_variable_set('@errors', errors)
    puts "Game loaded from #{filename}."
    game
  end

end

class Hangman
  def draw(errors)
    case errors
    when 0
      puts "  +---+"
      puts "  |   |"
      puts "  |   "
      puts "  |  "
      puts "  |  "
      puts " _|_"
      puts "|   |______"
      puts "|          |"
      puts "|__________|"
    when 1
      puts "  +---+"
      puts "  |   |"
      puts "  |   O"
      puts "  |  "
      puts "  |  "
      puts " _|_"
      puts "|   |______"
      puts "|          |"
      puts "|__________|"
    when 2
      puts "  +---+"
      puts "  |   |"
      puts "  |   O"
      puts "  |   |"
      puts "  |  "
      puts " _|_"
      puts "|   |______"
      puts "|          |"
      puts "|__________|"
    when 3
      puts "  +---+"
      puts "  |   |"
      puts "  |   O"
      puts "  |  /|"
      puts "  |  "
      puts " _|_"
      puts "|   |______"
      puts "|          |"
      puts "|__________|"
    when 4
      puts "  +---+"
      puts "  |   |"
      puts "  |   O"
      puts "  |  /|\\"
      puts "  |  "
      puts " _|_"
      puts "|   |______"
      puts "|          |"
      puts "|__________|"
    when 5
      puts "  +---+"
      puts "  |   |"
      puts "  |   O"
      puts "  |  /|\\"
      puts "  |  / "
      puts " _|_"
      puts "|   |______"
      puts "|          |"
      puts "|__________|"
    when 6
      puts "  +---+"
      puts "  |   |"
      puts "  |   O"
      puts "  |  /|\\"
      puts "  |  / \\"
      puts " _|_"
      puts "|   |______"
      puts "|          |"
      puts "|__________|"
    end
  end
end


word_bank = WordBank.new(word_bank)
game = Game.new(word_bank)
game.start



#class Player
  #responsible for managing the player's guesses and progress in the game - does not need to inherit from any other class
#end

    