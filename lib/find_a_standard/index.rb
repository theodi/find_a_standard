module FindAStandard
  class Index

    def initialize(url)
      @url = url
    end

    private

      def page_text
        body = open(@url).read
        html = Oga.parse_html(body)
        html.at_css('body').text.gsub(/\s+/, ' ').strip
      end

  end
end
