require File.dirname(__FILE__) + "/datch.rb"

def apply(db, &action)
  all = [*db]
  all.each { |d| action.call(d) }
end

def load_db(file)
  if File.directory? file
    result = []
    Dir.glob("#{file}/**/*.rb").each { |d|
      load d
      result << configure
    }
    result.flatten
  else
    load file
    configure
  end
end


commands={}
commands['init_db'] = lambda {
  db=load_db ARGV.shift
  apply(db) { |d| d.init_db }
}

commands['diff'] = lambda {
  db = load_db ARGV.shift
  dir=ARGV.shift
  output=ARGV.shift
  count=0
  apply(db) { |d|
    count = count +1
    id= output + count.to_s
    Datch::DatchParser.write_diff(dir, d, id)
  }
}

commands['upgrade'] = lambda {
  db=load_db ARGV.shift
  dir=ARGV.shift
  output=ARGV.shift
  count=0
  apply(db) { |d|
    count = count +1
    id= output + count.to_s
    Datch::DatchParser.write_diff(dir, d, id)
    d.exec_script(id +"/changes.sql")
  }
}

commands['run'] = lambda {
  db=load_db ARGV.shift
  while ARGV.size > 0
    script=ARGV.shift
    apply(db) { |d|
      puts d
      d.exec_script(script)
    }
  end
}

commands['exec'] = lambda {
  db=load_db ARGV.shift
  while ARGV.size > 0
    script=ARGV.shift
    apply(db) { |d|
      puts d
      d.exec_sql(script)
    }
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


