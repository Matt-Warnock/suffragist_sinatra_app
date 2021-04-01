# frozen_string_literal: true

class Page
  CHOICES = {
    'HAM' => 'Hamburger',
    'PIZ' => 'Pizza',
    'CUR' => 'Curry',
    'NOO' => 'Noodles'
  }.freeze

  attr_reader :title

  def initialize(title, database = nil)
    @title = title
    @database = database
  end

  def save(vote)
    @vote = vote
    database.transaction do
      database['votes'] ||= {}
      database['votes'][vote] ||= 0
      database['votes'][vote] += 1
    end
  end

  def casted_vote
    CHOICES[@vote]
  end

  def votes
    database.transaction { database['votes'] }
  end

  private

  attr_reader :database
end
