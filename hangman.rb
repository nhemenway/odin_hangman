require "json"

class Game
  def initialize(skip_select = false)
    @secret = make_secret
    @guesses = []
    play if skip_select
    select_game
  end

  def make_secret
    dictionary = "dictionary.txt"
    valid_words = []

    File.open(dictionary).readlines.each do |word|
      valid_words << word.strip.upcase if word.length.between?(6,13)
    end 

    valid_words.sample.split('')
  end


  def play
    until game_over?
      display_status
      puts "Make your guess. You have #{12 - @guesses.length} remaining."
      guess = get_guess
      check(guess)
    end
    end_game
  end

  def get_guess
    while true
      guess = gets.chomp.upcase
      break if legal_guess?(guess) || guess == "SAVE"
      puts "Illegal guess. Try again."
    end

    save if guess == "SAVE"
    @guesses << guess
    return guess
  end

  def check(guess)
    if @secret.include?(guess)
      puts "Correct! #{guess} is there."
    else
      puts "Incorrect. No #{guess} found."
    end
  end

  def legal_guess?(guess)
    !@guesses.include?(guess) && ("A".."Z").include?(guess)
  end

  def save
    game_status = {:time => Time.now, :secret => @secret, :guesses => @guesses}

    File.open("saves.json", "a") do |f|
      f.puts(game_status.to_json)
    end
    puts "You saved the game!"
    select_game
  end

  def show_saves
    File.open('saves.json').readlines.each_with_index do |l, i|
      json = JSON.parse(l)
      date = json["time"]
      puts "Load (#{i}) from #{date}"
      display_status(json["secret"], json["guesses"])
    end
    select_game
  end

  def select_game
    puts "Would you like to (c)ontinue, start a (n)ew game or (l)oad a save (number)?"
    response = gets.chomp.upcase
    Game.new(true) if response == "N" && !@guesses.empty?
    play if response == "C" || (response == "N" && @guesses.empty?)
    show_saves if response == "L" 
    load_save(response.to_i) =~ /d/
    play
  end

  def load_save(n)
    f = File.open('saves.json').readlines[n]
    json = JSON.parse(f)
    @secret = json["secret"]
    @guesses = json["guesses"]
  end

  def display_status(secret = @secret, guesses = @guesses)
    result = []
    secret.each do |l|
      guesses.include?(l) ? result << l : result << "_"
    end
    puts result.join(' ') + ' || ' + guesses.join
  end

  def game_over?
    won? || loss?
  end

  def loss?
    @guesses.length == 12
  end

  def won?
    done = true
    @secret.each do |l|
      done = false unless @guesses.include?(l)
    end
    done
  end

  def end_game
    if won?
      puts "Congrats! You won!"
    else
      puts "You lost."
    end

    puts "The answer was: " + @secret.join()
    puts "Let's play again."
    Game.new
  end

  # def to_json(*a)
  #   {
  #     "json_class"   => self.class.name,
  #     "data"         => {"secret" => @secret, "guesses" => @guesses}
  #   }.to_json(*a)
  # end

  # def self.json_create(o)
  #   new(o["data"]["string"], o["data"]["number"])
  # end

end

Game.new