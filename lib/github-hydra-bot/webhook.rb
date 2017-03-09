require "sinatra/base"
require "sinatra/contrib"
require "json"
require "pp"

module GitHubHydraBot

  REGEX = /@nixosbot build (?<sha>[a-z0-9]{40})/

  class WebHook < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    post "/issue_comment" do
      push = JSON.parse(request.body.read)
      pp push
      if push["action"] == "created" && (m = REGEX.match push["comment"]["body"])
        issue_id = push["issue"]["url"].split("/").last
        title = push["issue"]["title"]
        sha = m["sha"]
        gh_user_name = push["sender"]["login"]
        if $access_checker.has_access?(gh_user_name)
          hydra_url = HydraAPI.spawn(issue_id, title, sha)
          $commenter.comment(issue_id, "Hi @#{gh_user_name}, hydra build is [here](#{hydra_url})")
        else
          $commenter.comment(issue_id, "Sorry @#{gh_user_name}, you are not allowed to do this!")
        end
      end
    end
  end
end
