module GitHubHydraBot
  class GitHubAPI
    def initialize(oauth_token)
      @oauth_token = oauth_token
    end

    def login
      @login ||= fetch("https://api.github.com/user")["login"]
    end

    def fetch(url)
      uri = URI.parse(url)

      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri
        request["Accept"] = "application/vnd.github.v3+json"
        request["Authorization"] = "token " + @oauth_token
        http.request request
      end

      if response.code != "200"
        puts "Failed!"
        raise FetchException.new(url, response)
      end
      JSON.load(response.body)
    end

    def post(url, json)
      uri = URI.parse(url)

      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new uri
        request["Accept"] = "application/vnd.github.v3+json"
        request["Authorization"] = "token " + @oauth_token
        request["Content-Type"] = "application/json"
        request.body = JSON.dump(json)
        http.request request
      end

      if response.code != "201"
        puts "Failed!"
        raise FetchException.new(url, response)
      end
      JSON.load(response.body)
    end

    class FetchException < RuntimeError
      def initialize(url, response)
        super("Could not post '#{url}' from the API; got status #{response.code} #{response.body}")
      end
    end
  end
end
