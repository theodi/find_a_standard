require 'spec_helper'

describe FindAStandard::Index do

  before(:each) do
    stub_request(:get, "www.example.com").
      to_return(body: File.read(File.join 'spec', 'fixtures', 'index.html'))

    @index = described_class.new('http://www.example.com', 'description', 'comma,seperated,keywords')
  end

  it 'extracts the text from a webpage' do
    expect(@index.send(:page_text)).to match /Example Domain This domain is established to be used/
  end

  it 'extracts the title from a webpage' do
    expect(@index.send(:page_title)).to eq('Example Domain')
  end

  it 'indexes the text and title in Elasticsearch' do
    FindAStandard::Client.refresh_index
    expect(FindAStandard::Client.search('domain')['hits']['hits'].count).to eq(1)
    expect(FindAStandard::Client.search('domain')['hits']['hits'].first['_source']).to eq({
      'url' => 'http://www.example.com',
      'title' => 'Example Domain',
      'description' => 'description',
      'body' => 'Example Domain This domain is established to be used for illustrative examples in documents. You may use this domain in examples without prior coordination or asking for permission. More information...',
      'keywords' => ['comma','seperated','keywords']
    })
  end

  it 'copes with invalid characters' do
    stub_request(:get, "www.example.com").
      to_return(body: File.read(File.join 'spec', 'fixtures', 'invalid.html'))

    index = described_class.new('http://www.example.com', 'description', 'comma,seperated,keywords')

  end

end
