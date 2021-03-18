# frozen_string_literal: true

require_relative '../suffragist'

RSpec.describe 'Suffragist' do
  let(:file) { Tempfile.new('test.yml') }

  def app
    Suffragist.set :store, YAML::Store.new(file.path)
    Suffragist
  end

  after do
    file.close
    file.unlink
  end

  describe '/' do
    before { get '/' }

    it 'is succesful' do
      expect(last_response).to be_ok
    end

    it 'passes a title to the view' do
      expect(last_response.body).to include('Suffragist')
    end

    it 'lists all voting options' do
      expect(last_response.body.scan('name="vote"').count).to eq(4)
    end

    it 'sets the right id and value attribute and label' do
      expect(last_response.body).to match(%r{value="NOO" id="vote_NOO" />\n\s+Noodles})
    end
  end

  describe '/cast' do
    before { post '/cast', vote: 'NOO' }

    it 'is succesful' do
      expect(last_response).to be_ok
    end

    it 'passes a title to the view' do
      expect(last_response.body).to include('Thankyou for your vote!')
    end

    it 'it posts result' do
      expect(last_response.body).to include('Noodles')
    end

    it 'saves vote to the database' do
      database = YAML.load_file(file.path)
      expect(database['votes']['NOO']).to eq(1)
    end

    it 'accumulates votes to the database' do
      post '/cast', vote: 'NOO'
      database = YAML.load_file(file.path)

      expect(database['votes']['NOO']).to eq(2)
    end
  end

  describe '/results' do
    before do
      file.write({ 'votes' => { 'HAM' => 2 } }.to_yaml)
      file.rewind
      get '/results'
    end

    it 'is succesful' do
      expect(last_response).to be_ok
    end

    it 'shows all results' do
      expect(last_response.body.scan('class="food"').count).to eq(4)
    end

    it 'shows the vote count' do
      expect(last_response.body).to match(%r{Hamburger</th>\n\s+<td>2</td>\n\s+<td>##})
    end
  end

  describe '/unknown_path' do
    before { get '/unknown_path' }

    it 'is not succesful' do
      expect(last_response).to be_not_found
    end

    it 'correctly sets the title' do
      expect(last_response.body).to include('Oh no!')
    end
  end
end
