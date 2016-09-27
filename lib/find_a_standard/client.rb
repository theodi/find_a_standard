module FindAStandard
  class Client

    INDEX_NAME = 'find_a_standard'

    def self.index(url, title, body)
      body = {
        url: url,
        title: title,
        body: body
      }
      connection.index(index: INDEX_NAME, type: 'standard', body: body)
    end

    def self.search(query)
      body = {
        query: {
          match: {
            '_all' => query
          }
        }
      }
      connection.search(index: INDEX_NAME, body: body)
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

  end
end