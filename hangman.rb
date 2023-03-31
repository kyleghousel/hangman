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
  def initialize(word_bank, word=nil)
    @word_bank = word_bank
    if word
      @selected_word = word
    else
      @selected_word = @word_bank.select_random_word
    end
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
      if char == letter.downcase
        @displayed_word[index] = letter
        found = true
      end
    end
    found
  end
end

class Game
  def initialize(word_bank)
    @word_bank = word_bank
    @secret_word = Word.new(@word_bank)
    @display = Array.new(@secret_word.length, "_ ")
    @letters_guessed = []
    @hangman = Hangman.new
    @game_over = false
    @errors = 0
  end

  def menu
    puts "
    █░█ ▄▀█ █▄░█ █▀▀ █▀▄▀█ ▄▀█ █▄░█
    █▀█ █▀█ █░▀█ █▄█ █░▀░█ █▀█ █░▀█"
    puts "1. Start a new game"
    puts "2. Load a saved game"
    puts "3. Quit"
    print "What would you like to do? "
    
    choice = gets.chomp.to_i
    
    case choice
    when 1
      start
    when 2
      load_game
    when 3
      exit
    else
      puts "Invalid choice, please try again."
      menu
    end
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
      puts "Guess a letter, or enter 'save' to save the game:"
      input = gets.chomp.downcase
      if input == 'save'
        save_game('saved_game.json')
        puts "Game saved. Please enter another guess."
      elsif input.match?(/[a-z]/) && !@letters_guessed.include?(input) && input.length == 1
        return input
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
      word_bank: @word_bank,
      secret_word: @secret_word.to_s,
      display: @display,
      letters_guessed: @letters_guessed,
      errors: @errors,
      hangman: @hangman
    }
    File.open(filename, "w") do |file|
      file.write(JSON.generate(game_state))
    end
  end

  def load_game
    saved_data = File.read('saved_game.json')

    # Parse the JSON data and create new objects
    saved_state = JSON.parse(saved_data)
    secret_word = Word.new(@word_bank, saved_state["secret_word"])
    game = Game.new(@word_bank)
    @secret_word = game.instance_variable_set(:@secret_word, secret_word)
    @display = game.instance_variable_set(:@display, saved_state["display"])
    @letters_guessed = game.instance_variable_set(:@letters_guessed, saved_state["letters_guessed"])
    @errors = game.instance_variable_set(:@errors, saved_state["errors"])
    @secret_word
    @display
    @letters_guessed
    @errors

    # Start the loaded game
    game.start
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
game.menu



#class Player
  #responsible for managing the player's guesses and progress in the game - does not need to inherit from any other class
#end

    