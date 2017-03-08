module GitHubHydraBot
  class Commenter
    def initialize(api, github_owner, github_repo)
      @api = api
      @github_owner = github_owner
      @github_repo = github_repo
    end

    def comment(pr_id, comment_body)
      @api.post("https://api.github.com/repos/#{@github_owner}/#{@github_repo}/issues/#{pr_id}/comments", { body: comment_body })
    end
  end
end
