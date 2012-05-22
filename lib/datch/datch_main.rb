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

commands['upgrade'] = lambda {
  load ARGV.shift
  db=configure
  dir=ARGV.shift
  output=ARGV.shift
  Datch::DatchParser.write_diff(dir, db, output)
  db.exec_script(output +".changes.sql")
}

commands['run'] = lambda {
  load ARGV.shift
  db=configure
  while ARGV.size > 0
    script=ARGV.shift
    db.exec_script(script)
  end
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


