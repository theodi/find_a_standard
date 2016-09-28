require 'spec_helper'

describe FindAStandard::Client do

  it 'indexes the right data' do
    dbl = double(Elasticsearch::Client)

    expect(FindAStandard::Client).to receive(:connection) {
      dbl
    }

    expect(dbl).to receive(:index).with(index: 'find_a_standard_test', type: 'standard', body: {
      url: 'http://example.com',
      title: 'foo',
      description: 'a description',
      body: 'some really long bit of text',
      keywords: ['some', 'keywords', 'here']
    })

    FindAStandard::Client.index('http://example.com', 'foo', 'some really long bit of text', 'a description', ['some', 'keywords', 'here'])

    expect(FindAStandard::Client).to receive(:connection).and_call_original
  end

  it 'searches the title' do
    FindAStandard::Client.index('http://example.com', 'foo', 'some really long bit of text', 'description', ['key'])
    FindAStandard::Client.index('http://example.org', 'bar', 'some really long bit of text', 'description', ['key'])

    FindAStandard::Client.refresh_index

    results = FindAStandard::Client.search('foo')

    expect(results['hits']['hits'].count).to eq(1)

    expect(results['hits']['hits'].first['_source']).to eq({
      'url' => 'http://example.com',
      'title' => 'foo',
      'description' => 'description',
      'keywords' => ['key'],
      'body' => 'some really long bit of text'
    })
  end

  it 'searches the body' do
    FindAStandard::Client.index('http://example.com', 'foo', 'na na na na na na na na batman', 'description', ['key'])
    FindAStandard::Client.index('http://example.org', 'bar', 'na na na na na na na na leader', 'description', ['key'])

    FindAStandard::Client.refresh_index

    results = FindAStandard::Client.search('batman')

    expect(results['hits']['hits'].count).to eq(1)

    expect(results['hits']['hits'].first['_source']).to eq({
      'url' => 'http://example.com',
      'title' => 'foo',
      'description' => 'description',
      'keywords' => ['key'],
      'body' => 'na na na na na na na na batman'
    })

    expect(results['hits']['hits'].first['highlight']['body']).to eq(['na na na na na na na na <em>batman</em>'])
  end

  it 'searches keywords' do
    FindAStandard::Client.index('http://example.com', 'foo', 'na na na na na na na na batman', 'description', ['key'])
    FindAStandard::Client.refresh_index

    results = FindAStandard::Client.search('key')

    expect(results['hits']['hits'].count).to eq(1)

    expect(results['hits']['hits'].first['_source']).to eq({
      'url' => 'http://example.com',
      'title' => 'foo',
      'description' => 'description',
      'keywords' => ['key'],
      'body' => 'na na na na na na na na batman'
    })
  end

end
