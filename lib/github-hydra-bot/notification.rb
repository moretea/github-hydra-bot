module GitHubHydraBot
  class Notifcation
    attr_reader :command

    def initialize(bot_name, notification_with_latest_comment)
      @raw = notification_with_latest_comment

      bot_regex= /@#{bot_name} build (?<sha>[a-z0-9]{40})/m
      if (m = bot_regex.match(@raw["comment"]["body"])) != nil
        pr_id = @raw["subject"]["url"].split("/").last.to_i
        @command = Command::Build.new(pr_id, m["sha"], self.title)
      end
    end

    def id
      @raw["id"]
    end

    def title
      @raw["subject"]["title"]
    end

    def is_command?
      @command != nil
    end

    def comment_created_at
      Time.parse(@raw["comment"]["created_at"])
    end

    def comment_id
      @raw["comment"]["id"]
    end
  end
end
