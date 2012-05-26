require File.dirname(__FILE__) + "/datch.rb"
require 'optparse'

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

class CmdOptions

  attr_accessor :invoke

  @@COMMANDS = {}

  def initialize(name, description)
    @name = name
    @description = description
    @@COMMANDS[name] = self
    @options={}
    @args=[]
    @option_targets = []
  end

  def db_conf_path
    @args << "[db conf path]"
  end

  def schema_changes_path
    @args << "[schema changes path]"
  end

  def files_or_input
    @args << "[files or input]"
  end

  def optional_output_dir
    @options[:output] = "./"
    @option_targets << lambda{ | o|
      o.on('-o', '--output DIR', 'Output Dir') { |d|
        @options[:output] = d
      }
    }
  end

  def run_cmd
    opt_parser = OptionParser.new
    opt_parser.banner = "Command Usage: #@name #{@args.join(' ')}"
    opt_parser.separator ""
    opt_parser.separator @description
    opt_parser.separator ""
    opt_parser.separator "Switches:"

    opt_parser.on_tail("-h", "--help", "Command Help") {
      puts opt_parser
      exit
    }

    @option_targets.each { |t| t.call(opt_parser)}

    opt_parser.parse!
    if ARGV.size < @args.size
      puts opt_parser
      exit -1
    end
    @invoke.call(@options)
  end

  def self.parse
    if ARGV.size == 0
      puts "Available commands: #{@@COMMANDS.keys.inspect}"
      puts "Type command -h or --help for command specific help"
      exit -1
    end

    command = ARGV.shift

    if @@COMMANDS.include? command
      @@COMMANDS[command].run_cmd
    else
      puts "Command #{command} not found in : #{@@COMMANDS.keys.inspect}"
      exit -1
    end
  end

end
init_db=CmdOptions.new("init_db", "Initialize Database(s) with datch version table")
init_db.db_conf_path
init_db.invoke = lambda { |opts|
  db=load_db ARGV.shift
  apply(db) { |d| d.init_db }
}

diff = CmdOptions.new 'diff', "Uses the version table to generate a change script from available patches"
diff.db_conf_path
diff.schema_changes_path
diff.optional_output_dir
diff.invoke  = lambda { |opts|
  db = load_db ARGV.shift
  dir=ARGV.shift
  output=options[:output]
  count=0
  apply(db) { |d|
    count = count +1
    id= output + count.to_s
    Datch::DatchParser.write_diff(dir, d, id)
  }
}

upgrade = CmdOptions.new 'upgrade', "Uses the version table to generate a set of changes and apply them to database(s)"
upgrade.db_conf_path
upgrade.schema_changes_path
upgrade.optional_output_dir
upgrade.invoke = lambda { |opts|
  db=load_db ARGV.shift
  dir=ARGV.shift
  output=opts[:output]
  count=0
  apply(db) { |d|
    count = count +1
    id= output + count.to_s
    Datch::DatchParser.write_diff(dir, d, id)
    d.exec_script(id +"/changes.sql")
  }
}

run = CmdOptions.new 'run', "Run sql provided from file(s) or from input stream"
run.db_conf_path
run.files_or_input
run.invoke = lambda { |opts|
  db=load_db ARGV.shift
  result = ""
  ARGF.each_line { |l|
    result += l + "\n"
  }
  apply(db) { |d|
    puts d
    d.exec_sql(result)
  }
}

CmdOptions.parse


