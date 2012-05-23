require File.dirname(__FILE__) + "/datch.rb"

def apply(db, &action)
  all = [*db]
  all.each{|d| action.call(d)}
end

commands={}
commands['init_db'] = lambda{
  load ARGV.shift
  db=configure
  apply(db){|d| d.init_db}
}

commands['diff'] = lambda {
  load ARGV.shift
  db=configure
  dir=ARGV.shift
  output=ARGV.shift
  count=0
  apply(db){|d|
    count = count +1
    id= output + count.to_s
    Datch::DatchParser.write_diff(dir, d, id)
  }
}

commands['upgrade'] = lambda {
  load ARGV.shift
  db=configure
  dir=ARGV.shift
  output=ARGV.shift
  count=0
  apply(db){|d|
    count = count +1
    id= output + count.to_s
    Datch::DatchParser.write_diff(dir, d, id)
    d.exec_script(id +".changes.sql")
  }
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


