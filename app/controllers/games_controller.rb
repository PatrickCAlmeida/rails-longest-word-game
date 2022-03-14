require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    @score = run_game(params[:answer], JSON.parse(params[:letters]))
    # @score = JSON.parse(params[:letters])
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    alpha = ('A'..'Z').to_a
    letteres = []
    while grid_size.positive?
      letteres << alpha[rand(0..25)]
      grid_size -= 1
    end
    letteres
  end

  def run_game(attempt, grid)
    session[:total] = 0 if session[:total].nil?
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_serialized = URI.open(url).read
    hash = JSON.parse(word_serialized)
    attempt.chars.each do |item|
      if grid.include?(item.to_s.upcase)
        grid.delete_at(grid.index(item.to_s.upcase) || grid.length)
      else
        @message = "Sorry but <strong>#{attempt.to_s.upcase}</strong> can't be build out of #{grid.join(" ")} score #{session[:total]}"
        return @message
      end
    end
      if hash["found"] == true # found = true
        session[:total] += attempt.length
        @message = "<strong>Congratulations!</strong> #{attempt.to_s.upcase} is a valid English word! score #{session[:total]} "
      else # word["found"] = false
        @message = "Sorry but <strong>#{attempt.to_s.upcase}</strong> does not seem to be a valid English word... score #{session[:total]}"
      end
      @message
  end
end
