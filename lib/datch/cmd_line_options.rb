require 'optparse'

module Datch
  class CmdLineOptions

    attr_accessor :git_url, :git_opts

    def self.parse(*args)
      options = CmdLineOptions.new
      OptionParser.new do |opts|
        opts.banner = "Usage: datch.rb [options]"

        opts.separator ""
        opts.separator "Specific options:"

        # Mandatory argument.
        opts.on("-g", "--git GIT_URL",
                "Require the GIR_URL for retrieving versions ") do |url|
          options.git_url= url
        end
        opts.on("-o", "--options", "git command line options for finding patches") do |o|
          options.git_opts=o
        end
      end.parse! args
      options
    end
  end
end