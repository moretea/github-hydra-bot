module GitHubHydraBot
  module Command
    class Build
      attr_reader :pr_id, :sha, :title

      def initialize(pr_id, sha, title)
        @pr_id = pr_id
        @sha = sha
        @title = title
      end
    end
  end
end
