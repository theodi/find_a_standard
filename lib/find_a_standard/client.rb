module FindAStandard
  class Client

    INDEX_NAME = ENV['FIND_A_STANDARD_INDEX']

    def self.index(url, title, body, description, keywords)
      body = {
        url: url,
        title: title,
        description: description,
        body: encode(body),
        keywords: keywords
      }
      connection.index(index: INDEX_NAME, type: 'standard', body: body)
    end

    def self.search(query)
      body = {
        query: {
          match: {
            '_all' => query
          }
        },
        highlight: {
          fields: {
            body: {
              fragment_size: 400,
              number_of_fragments: 1
            }
          }
        }
      }
      connection.search(index: INDEX_NAME, body: body)
    end

    def self.all
      count = connection.search(index: INDEX_NAME)['hits']['total']
      connection.search(index: INDEX_NAME, size: count)
    end

    def self.create_index
      connection.indices.create(index: INDEX_NAME)
    end

    def self.delete_index
      connection.indices.delete(index: INDEX_NAME)
    end

    def self.refresh_index
      connection.indices.refresh(index: INDEX_NAME)
    end

    def self.connection
      @@connection ||= Elasticsearch::Client.new url: ENV['ES_URL']
    end

    private

      def self.encode(str)
        str.encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
      end

  end
end
