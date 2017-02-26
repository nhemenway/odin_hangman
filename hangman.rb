class Game
  def initialize
    @secret = make_secret
    @guess_count = 0
    @guesses = []
    play
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
      puts "Make your guess. You have #{12 - @guess_count} remaining."
      while true
        guess = gets.chomp[0].upcase
        if legal_guess?(guess) then break end
        puts "Illegal guess. Try again."
      end
      @guesses << guess
      @guess_count += 1
      check(guess)
    end
    end_game
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

  def display_status
    result = []
    @secret.each do |l|
      @guesses.include?(l) ? result << l : result << "_"
    end
    puts result.join(' ') + ' || ' + @guesses.join
  end

  def game_over?
    won? || loss?
  end

  def loss?
    @guess_count == 12
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

end

Game.new