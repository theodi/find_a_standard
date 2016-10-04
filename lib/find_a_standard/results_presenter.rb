module FindAStandard
  class ResultsPresenter

    def initialize(result)
      @result = result
    end

    def title
      @result['_source']['title']
    end

    def url
      @result['_source']['url']
    end

    def description
      @result['_source']['description']
    end

    def body
      if !@result['highlight'].nil?
        "...#{@result['highlight']['body'].first}..."
      else
        ''
      end
    end

    def keywords
      (@result['_source']['keywords'] || []).map { |k| k.strip }
    end

  end
end
