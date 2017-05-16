require 'open-uri'
require 'json'

class GameController < ApplicationController
  def home
    @grid = generate_grid(9)
    @start_time = Time.now()
  end

  def score
    @end_time = Time.now()
    @start_time = Time.parse(params[:start_time])
    @guess = params[:word].split("")
    @grid = params[:grid].split("")
    @result = run_game(@guess, @grid, @start_time, @end_time)

  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end


  def included?(guess, grid)
    guess.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(guess, time_taken)
    (time_taken > 60.0) ? 0 : guess.size * (1.0 - time_taken / 60.0)
  end

  def run_game(guess, grid, start_time, end_time)
    result = { time: end_time - start_time }

    result[:translation] = get_translation(guess)
    result[:score], result[:message] = score_and_message(
      guess, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(guess, translation, grid, time)
    if included?(guess, grid)
      if translation
        score = compute_score(guess, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "bb3687f1-9250-473e-9929-e202ca399561"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.join.upcase
        return word
      else
        return nil
      end
    end
  end



end
