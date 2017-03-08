module GitHubHydraBot
  module HydraAPI
    def self.spawn pullrequest_id, description, sha
      cmd = "hydra-create-or-update-jobset nixos --triger --pull-request #{pullrequest_id} --description #{Shellwords.escape(description)} --sha #{sha}"
      puts "SPAWNING HYDRA JOBSET WITH: #{cmd}"
      system(cmd)

      "https://some-host/nixos/#{pullrequest_id}"
    end
  end
end
