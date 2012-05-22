require File.dirname(__FILE__) + "/datch.rb"

commands={}
commands['init_db'] = lambda{
  load ARGV.shift
  db=configure
  db.init_db
}

commands['diff'] = lambda {
  load ARGV.shift
  db=configure
  dir=ARGV.shift
  output=ARGV.shift
  Datch::DatchParser.write_diff(dir, db, output)
}

if ARGV.size == 0
  puts "Available commands: #{commands.keys.inspect}"
  exit -1
end

command = ARGV.shift

if commands.include? command
  commands[command].call
else
  puts "Command #{command} not found in : #{commands.keys.inspect}"
  exit -1
end


