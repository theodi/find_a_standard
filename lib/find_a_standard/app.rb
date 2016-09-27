module FindAStandard
  class App < Sinatra::Base

    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['FIND_A_STANDARD_USERNAME'], ENV['FIND_A_STANDARD_PASSWORD']]
    end

    get '/' do
      erb :index, layout: 'layouts/default'.to_sym
    end

    get '/search' do
      @query = params[:q]
      @results = FindAStandard::Client.search(@query)
      erb :results, layout: 'layouts/default'.to_sym
    end

    post '/index' do
      protected!

      FindAStandard::Index.new(params[:url])
    end

  end
end
