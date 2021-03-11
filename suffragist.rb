# frozen_string_literal: true

require 'sinatra'
require 'yaml/store'

CHOICES = {
  'HAM' => 'Hamburger',
  'PIZ' => 'Pizza',
  'CUR' => 'Curry',
  'NOO' => 'Noodles'
}.freeze

get '/' do
  @title = 'Welcome to the Suffragist!'
  erb :index
end

post '/cast' do
  @title = 'Thankyou for your vote!'
  @vote = params['vote']

  @store = YAML::Store.new 'votes.yaml'
  @store.transaction do
    @store['votes'] ||= {}
    @store['votes'][@vote] ||= 0
    @store['votes'][@vote] += 1
  end

  erb :cast
end

get '/results' do
  @store = YAML::Store.new 'votes.yaml'
  @votes = @store.transaction { @store['votes'] }

  erb :results
end
