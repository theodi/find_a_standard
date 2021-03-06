module FindAStandard
  class App < Sinatra::Base
    register Sinatra::RespondTo

    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['FIND_A_STANDARD_USERNAME'], ENV['FIND_A_STANDARD_PASSWORD']]
    end

    def map_results(results)
      results.map do |r|
        {
          title: r['_source']['title'],
          url: r['_source']['url'],
          description: r['_source']['description'],
          keywords: r['_source']['keywords']
        }
      end.sort { |a,b| a[:title] <=> b[:title] }
    end

    def generate_csv(results)
      csv = map_results(results).map do |r|
        r[:keywords] = r[:keywords].join(',')
        r.values
      end
      csv.unshift(['title', 'url', 'description', 'keywords'])
      csv.map { |r| r.to_csv(row_sep: "\r\n") }.join
    end

    get '/' do
      @title = 'Find a standard'
      erb :index, layout: 'layouts/default'.to_sym
    end

    get '/submit' do
      @title = 'Submit a standard'
      erb :submit, layout: 'layouts/default'.to_sym
    end

    get '/search' do
      @title = 'Search Results'
      @query = params[:q]
      display_results(@query, '_all')
    end

    get '/tag/:tag_id' do
      @title = "Results with tag `#{params[:tag_id]}`"
      display_results(params[:tag_id], 'keywords')
    end

    get '/data' do
      @title = 'Find a standard - Data'
      @results = FindAStandard::Client.all['hits']['hits']
      respond_to do |wants|
        wants.html do
          erb :data, layout: 'layouts/default'.to_sym
        end
        wants.json do
          map_results(@results).to_json
        end
        wants.csv do
          generate_csv(@results)
        end
      end
    end

    post '/index' do
      protected!

      FindAStandard::Index.new(params[:url], params[:description], params[:keywords])
    end

    private

      def display_results(query, match)
        hits = FindAStandard::Client.search(query, match)['hits']['hits']
        respond_to do |wants|
          wants.html do
            @results = hits.map { |h| FindAStandard::ResultsPresenter.new(h) }
            erb :results, layout: 'layouts/default'.to_sym
          end
          wants.json do
            map_results(hits).to_json
          end
          wants.csv do
            generate_csv(hits)
          end
        end
      end

  end
end
