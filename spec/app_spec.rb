require 'spec_helper'

describe FindAStandard::App do

  it 'returns 401 if not authorized' do
    post '/index', url: 'http://example.org'

    expect(last_response.status).to eq(401)
  end

  it 'indexes a url' do
    stub_request(:get, "www.example.com").
      to_return(body: File.read(File.join 'spec', 'fixtures', 'index.html'))

    authorize ENV['FIND_A_STANDARD_USERNAME'], ENV['FIND_A_STANDARD_PASSWORD']
    post '/index', url: 'http://example.org', description: 'foo bar', keywords: 'ffdsfds,dfsfdssd'

    expect(last_response.status).to eq(200)

    FindAStandard::Client.refresh_index
    expect(FindAStandard::Client.search('domain')['hits']['hits'].count).to eq(1)
  end

  it 'gets the homepage' do
    get '/'

    expect(last_response.body).to match /Find a standard/
  end

  context 'search' do

    before(:each) do
      FindAStandard::Client.index('http://example.com/murderverse', 'foo', 'Batman vs Superman', 'description', ['key'])
      FindAStandard::Client.index('http://example.org', 'bar', 'superman', 'description', ['key','other key', 'thing'])
      FindAStandard::Client.index('http://example.com/adam-west', 'baz', 'na na na na na na na na batman', 'description', ['key'])

      FindAStandard::Client.refresh_index
    end

    it 'with HTML' do
      get '/search', q: 'batman'

      expect(last_response.body).to match /http:\/\/example.com\/murderverse/
      expect(last_response.body).to match /foo<\/a>/

      expect(last_response.body).to match /http:\/\/example.com\/adam-west/
      expect(last_response.body).to match /baz<\/a>/
    end

    it 'with JSON' do
      get '/search.json', q: 'batman'

      json = JSON.parse(last_response.body)

      expect(json.count).to eq(2)
    end

    it 'with CSV' do
      get '/search.csv', q: 'batman'

      csv = CSV.parse(last_response.body)

      expect(csv.count).to eq(3)
    end

  end

  context 'data' do

    before(:each) do
      FindAStandard::Client.index('http://example.com/murderverse', 'foo', 'Batman vs Superman', 'description', ['key'])
      FindAStandard::Client.index('http://example.org', 'bar', 'superman', 'description', ['key','other key', 'thing'])
      FindAStandard::Client.index('http://example.com/adam-west', 'baz', 'na na na na na na na na batman', 'description', ['key'])

      FindAStandard::Client.refresh_index
    end

    it 'gets the data as JSON' do
      get '/data.json'

      json = JSON.parse(last_response.body)

      expect(json.count).to eq(3)

      expect(json[0]).to eq({
        'title' => 'bar',
        'url' => 'http://example.org',
        'description' => 'description',
        'keywords' => ['key','other key', 'thing']
      })
      expect(last_response.headers["Content-Type"]).to eq('application/json')
    end

    it 'gets the data as CSV' do
      get '/data.csv'

      csv = CSV.parse(last_response.body)

      expect(csv.count).to eq(4)

      expect(csv[1]).to eq([
        'bar', 'http://example.org', 'description', 'key,other key,thing'
      ])
      expect(last_response.headers["Content-Type"]).to eq('text/csv;charset=utf-8')
    end

  end

  it 'gets tags' do
    FindAStandard::Client.index('http://example.org/superman', 'bar', 'Superman', 'description', ['tag','other key', 'thing'])
    FindAStandard::Client.index('http://example.com/adam-west', 'baz', 'na na na na na na na na batman', 'description', ['key'])

    FindAStandard::Client.refresh_index

    get '/tag/thing'

    expect(last_response.body).to match /http:\/\/example.org\/superman/
    expect(last_response.body).to match /bar/
  end

end
