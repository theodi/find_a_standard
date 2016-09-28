require 'spec_helper'

describe FindAStandard::ResultsPresenter do

  it 'presents a result' do
    result = {
      '_source' => {
        'url' => 'http://example.com',
        'title' => 'foo',
        'description' => 'description',
        'keywords' => ['key'],
        'body' => 'na na na na na na na na batman',
      },
      'highlight' => {
        'body' => ['na na na na na na na na <i>batman</i>']
      }
    }

    presenter = FindAStandard::ResultsPresenter.new(result)

    expect(presenter.url).to eq('http://example.com')
    expect(presenter.title).to eq('foo')
    expect(presenter.description).to eq('description')
    expect(presenter.keywords).to eq(['key'])
    expect(presenter.body).to eq('...na na na na na na na na <i>batman</i>...')
  end

  it 'returns defaults' do
    result = {
      '_source' => {
        'url' => 'http://example.com',
        'title' => 'foo',
        'description' => 'description',
        'body' => 'na na na na na na na na batman',
      }
    }

    presenter = FindAStandard::ResultsPresenter.new(result)
    expect(presenter.body).to eq('')
    expect(presenter.keywords).to eq([])
  end

end
