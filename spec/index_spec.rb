require 'spec_helper'

describe FindAStandard::Index do

  before(:each) do
    stub_request(:get, "www.example.com").
      to_return(body: File.read(File.join 'spec', 'fixtures', 'index.html'))

    @index = described_class.new('http://www.example.com')
  end

  it 'extracts the text from a webpage' do
    expect(@index.send(:page_text)).to match /Example Domain This domain is established to be used/
  end

  it 'extracts the title from a webpage' do
    expect(@index.send(:page_title)).to eq('Example Domain')
  end

end
