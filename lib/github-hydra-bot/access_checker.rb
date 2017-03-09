module GitHubHydraBot
  class AccessChecker
    def initialize(file)
      @file_name = file
    end

    def has_access?(gh_user)
      File.read(@file_name).split("\n").include?(gh_user)
    end
  end
end
