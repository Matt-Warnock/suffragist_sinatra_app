# frozen_string_literal: true

require 'sinatra'
require 'yaml/store'

require_relative 'lib/page'

class Suffragist < Sinatra::Base
  set :store, YAML::Store.new('votes.yaml')

  get '/' do
    @page = Page.new('Welcome to the Suffragist!')
    erb :index
  end

  post '/cast' do
    @page = Page.new('Thankyou for your vote!', settings.store)
    @page.save(params['vote'])

    erb :cast
  end

  get '/results' do
    @page = Page.new('Results so far:', settings.store)

    erb :results
  end

  not_found do
    @page = Page.new('Oh no!')
    status 404
    erb :oh_no
  end
end
