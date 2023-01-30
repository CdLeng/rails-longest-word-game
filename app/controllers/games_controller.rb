require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.sample(10)
    session[:has_played] = nil
  end

  def score
    @word = params[:word]
    @letters = params[:letters].split
  end

  private

  def compute_score(guess)
    2**guess.size
  end

  def score_and_message(guess, grid)
    if included?(guess.upcase, grid)
      if english_word?(guess)
        @new_score = compute_score(guess)
        if session[:has_played].nil?
          session[:user_score] += @new_score
          session[:has_played] = true
        end
        "Well done! #{guess.capitalize} is an valid English word! \n Your score is #{session[:user_score].round(2)}"
      else
        "Sorry, but #{guess} doesn't seem to be in the English dictionary."
      end
    else
      "Sorry, but #{guess} can't be built of out of #{grid.join(', ')}"
    end
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    @response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}").read
    @json = JSON.parse(@response)
    @json['found']
  end

  helper_method :compute_score, :score_and_message, :included?, :english_word?
end
