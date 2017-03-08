module GitHubHydraBot
  class Commenter
    def initialize(api, github_owner, github_repo)
      @api = api
      @github_owner = github_owner
      @github_repo = github_repo
    end

    def reply_to_comment(pr_id, comment_id, comment_body)
      @api.post("https://api.github.com/repos/#{@github_owner}/#{@github_repo}/#{pr_id}/comments", { body: comment_body, in_reply_to: comment_id })
    end
  end
end
