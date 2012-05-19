require File.dirname(__FILE__) + '/cmd_line_options.rb'

puts ARGV.inspect

options = Datch::CmdLineOptions.parse *ARGV

puts options.inspect