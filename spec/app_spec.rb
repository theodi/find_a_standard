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

  it 'carries out a simple search' do
    FindAStandard::Client.index('http://example.com/murderverse', 'foo', 'Batman vs Superman', 'description', ['key'])
    FindAStandard::Client.index('http://example.org', 'bar', 'superman', 'description', ['key'])
    FindAStandard::Client.index('http://example.com/adam-west', 'baz', 'na na na na na na na na batman', 'description', ['key'])

    FindAStandard::Client.refresh_index

    get '/search', q: 'batman'

    expect(last_response.body).to match /http:\/\/example.com\/murderverse/
    expect(last_response.body).to match /foo<\/a>/

    expect(last_response.body).to match /http:\/\/example.com\/adam-west/
    expect(last_response.body).to match /baz<\/a>/

  end

end
