module GitHubHydraBot
  class State
    def initialize(dir)
      unless Dir.exist?(dir)
        FileUtils.mkdir_p(dir)
      end
      @last_fetched_ok_file = File.join(dir, "last_fetched_ok")
      @already_seen_file = File.join(dir, "already_seen")
    end

    def last_fetched_ok
      if File.exists?(@last_fetched_ok_file)
        Time.parse(File.read(@last_fetched_ok_file))
      else
        nil
      end
    end

    def set_last_fetched_ok!(last_ok)
      File.write(@last_fetched_ok_file, last_ok.utc.to_s)
    end

    def already_seen?(notification_id)
      if File.exists?(@already_seen_file)
        File.open(@already_seen_file, "r") do |f|
          f.each_line do |l|
            return true if notification_id == l.chomp
          end
          f.close
        end
      end

      false
    end

    def mark_as_already_seen!(notification_id)
      File.open(@already_seen_file, "a") do |f|
        f.puts notification_id
        f.close
      end
    end
  end
end
