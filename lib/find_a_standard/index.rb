module FindAStandard
  class Index

    def initialize(url)
      @url = url
      FindAStandard::Client.index(url, page_title, page_text)
    end

    private

      def page_text
        html.at_css('body').text.gsub(/\s+/, ' ').strip
      end

      def page_title
        html.at_css('title').text.gsub(/\s+/, ' ').strip
      end

      def html
        body = open(@url).read
        html = Oga.parse_html(body)
      end

  end
end
