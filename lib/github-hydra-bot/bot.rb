module GitHubHydraBot
  SLEEPY_SLEEPY = 60 # Sleep 60 seconds

  class Bot
    def initialize(state_dir:, oauth_token:, github_owner:, github_repo:)
      @state = State.new(state_dir)
      api = GitHubAPI.new(oauth_token)
      @commenter = Commenter.new(api, github_owner, github_repo)
      @fetcher = Fetcher.new(api, github_owner, github_repo)
    end

    def main_loop
      log "Fetching notifications"
      notifications = @fetcher.get_notifications(since: @state.last_fetched_ok)

      if notifications.empty?
        log "No new notifications found"
      else
        # Only handle commands
        commands = notifications.select { |n| n.is_command? }

        # Do not process the same commands twice
        new_commands = commands.reject { |n| @state.already_seen?(n.id) }

        new_commands.each do |new_command|
          log "Handling command"
          handle new_command
        end

        latest_comment = new_commands.map { |n| n.comment_created_at }.max
        if latest_comment
          @state.set_last_fetched_ok!(latest_comment - 1) # One second before, to not miss anything
        end
      end

      log "Sleeping for #{SLEEPY_SLEEPY} seconds..."
      sleep SLEEPY_SLEEPY
      log "Waking up!"
    end

    private
    def handle notification
      raise "unexpected notification " if notification.command.class != Command::Build
      cmd = notification.command
      url = HydraAPI.spawn(cmd.pr_id, cmd.title, cmd.sha)
      @commenter.comment(cmd.pr_id, "Hydra PR: #{url}")
      @state.mark_as_already_seen!(notification.id)
    end

    def log(msg)
      puts "[#{Time.now.utc.to_s}] #{msg}"
    end
  end
end
