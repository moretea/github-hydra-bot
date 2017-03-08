module GitHubHydraBot
  class Fetcher
    def initialize(api, owner, repo)
      @api =api
      @owner = owner
      @repo = repo
    end

    # Get notifications
    # Since must be a Time object,if provided
    def get_notifications(since: nil)
      url = "https://api.github.com/repos/#{@owner}/#{@repo}/notifications?all=true"
      if since
        url += "&since=#{since.iso8601}"
      end

      notifications = @api.fetch(url)
      # We're only interested in mentions in PR's for now.
      notifications.select! do |notification|
        (notification["reason"] == "mention") && notification["subject"]["type"] == "PullRequest"
      end

      # Now add the comment to it.
      notifications.map do |notification|
        notification["comment"] = @api.fetch(notification["subject"]["latest_comment_url"])
      end

      notifications.map! { |item| Notifcation.new(@api.login, item) }
    end

  end
end
