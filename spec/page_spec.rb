# frozen_string_literal: true

require 'page'
require 'yaml/store'

RSpec.describe Page do
  let(:file) { Tempfile.new('test.yml') }
  let(:database) { YAML::Store.new(file.path) }
  let(:page) { described_class.new('', database) }

  after do
    file.close
    file.unlink
  end

  describe '#save' do
    it 'saves vote to the database' do
      page.save('HAM')

      results_hash = database.transaction { database['votes'] }

      expect(results_hash.keys.first).to eq('HAM')
    end

    it 'accumulates votes to the database' do
      page.save('HAM')
      page.save('HAM')

      results_hash = database.transaction { database['votes'] }

      expect(results_hash['HAM']).to eq(2)
    end
  end

  describe '#casted_vote' do
    it 'returns vote cast value saved to database' do
      page.save('HAM')

      expect(page.casted_vote).to eq('Hamburger')
    end
  end

  describe '#votes' do
    it 'returns votes hash from database' do
      vote_hash = { 'HAM' => 2 }
      file.write({ 'votes' => vote_hash }.to_yaml)
      file.rewind

      expect(page.votes).to eq(vote_hash)
    end
  end
end
