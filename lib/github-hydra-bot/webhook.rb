module GitHubHydraBot
  REGEX = /@#{$bot_name} build (?<sha>[a-z0-9]{40})/

  class WebHook < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    post "/issue_comment" do
      request.body.rewind
      payload_body = request.body.read
      verify_signature(payload_body)

      push = JSON.parse(payload_body)

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

    def verify_signature(payload_body)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), $webhook_secret, payload_body)
      if !Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
        return halt 500, "Signatures didn't match!"
      end
    end
  end
end
