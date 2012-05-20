require File.dirname(__FILE__) + "/datch.rb"

commands={}
commands['init_db'] = lambda{
  load ARGV.shift
  db=configure
  db.init
}

commands['diff'] = lambda {
  dir=ARGV.shift
  output=ARGV.shift
  load ARGV.shift
  db=configure
  parser = DatchParser.new(dir, db)
  parser.write_change_sql(output)
  parser.write_rollback_sql(output)
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


