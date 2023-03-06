require "open-uri"
require "json"

INVALID_GRID_ERROR = {
  time: "",
  score: 0,
  message: "Not in the grid",
}

INVALID_ENGLISH_ERROR = {
  time: "",
  score: 0,
  message: "Not an english word",
}

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    @grid = params[:grid].split("")
    @attempt = params[:attempt]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now

    has_error = false
    has_error = !attempt_valid(@attempt, @grid)
    if has_error
      @result = INVALID_GRID_ERROR
    else
      data = word_data(@attempt)
      has_error = data["found"] != true
      @result = has_error ? INVALID_ENGLISH_ERROR : compute_result(@attempt, @start_time, @end_time)
    end
  end

  private

  def random_letter
    alphabet = ("A".."Z").to_a
    i = rand(alphabet.length)
    alphabet[i]
  end

  def generate_grid(grid_size)
    letters = []
    (0...grid_size).each { letters << random_letter }
    letters
  end

  def attempt_valid(attempt, grid)
    attempt = attempt.upcase.chars
    until attempt.empty?
      char = attempt.pop
      return false unless grid.include?(char)

      index = grid.find_index(char)
      grid.delete_at(index)
    end
    true
  end

  def word_data(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    JSON.parse(URI.open(url).read)
  end

  def compute_result(attempt, start_time, end_time)
    time = end_time - start_time
    score = attempt.length + (1 / (1 + time) * 10)
    {
      score: score.round(3),
      message: "Well done",
      time: time,
    }
  end
end
