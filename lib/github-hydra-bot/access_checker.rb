module GitHubHydraBot
  class AccessChecker
    def initialize(file)
      @people_with_access = File.read(file).split("\n")
    end

    def has_access?(gh_user)
      @people_with_access.include?(gh_user)
    end
  end
end
