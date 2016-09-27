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
    post '/index', url: 'http://example.org'

    expect(last_response.status).to eq(200)

    FindAStandard::Client.refresh_index
    expect(FindAStandard::Client.search('domain')['hits']['hits'].count).to eq(1)
  end

  it 'gets the homepage' do
    get '/'

    expect(last_response.body).to match /Find a standard/
  end

  it 'carries out a simple search' do
    FindAStandard::Client.index('http://example.com', 'foo', 'Batman vs Superman')
    FindAStandard::Client.index('http://example.org', 'bar', 'superman')
    FindAStandard::Client.index('http://example.com', 'baz', 'na na na na na na na na batman')

    FindAStandard::Client.refresh_index

    get '/search', q: 'batman'

    expect(last_response.body).to match /<h2>foo/
    expect(last_response.body).to match /<h2>baz/
  end

end
