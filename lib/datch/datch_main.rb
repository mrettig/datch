require File.dirname(__FILE__) + "/datch.rb"
require 'optparse'

def load_db(file)
  if File.directory? file
    result = []
    Dir.glob("#{file}/**/*.rb").each { |d|
      load d
      result << configure
    }
    Datch::DbArray.new(result.flatten)
  else
    load file
    Datch::DbArray.new(configure)
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
    @files_or_input=true
  end

  def optional_output_dir
    @options[:output] = "./"
    @option_targets << lambda{ | o|
      o.on('-o', '--output DIR', 'Output Dir. Defaults to current dir.') { |d|
        @options[:output] = d
      }
    }
  end

  def optional_max_version
    @options[:max_version] = nil
    @option_targets << lambda{ | o|
      o.on('-e', '--end MAX', Integer, 'Max version included (inclusive) for patch diff.') { |d|
        @options[:max_version] = d
      }
    }
  end

  def optional_min_version
    @options[:min_version] = nil
    @option_targets << lambda{ | o|
      o.on('-s', '--start MIN', Integer, 'Min version (exclusive) for patch diff.') { |d|
        @options[:min_version] = d
      }
    }
  end

  def run_cmd
    opt_parser = OptionParser.new
    msg = "Command Usage: #@name #{@args.join(' ')}"
    if @files_or_input
      msg += " [files or input]"
    end
    opt_parser.banner = msg
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
  db.init_db
}

def apply_diff(cmd_options, &post_diff)
  cmd_options.db_conf_path
  cmd_options.schema_changes_path
  cmd_options.optional_output_dir
  cmd_options.optional_min_version
  cmd_options.optional_max_version
  cmd_options.invoke  = lambda { |opts|
    db = load_db ARGV.shift
    dir=ARGV.shift
    output=opts[:output]
    post_diff.call(db, dir, output, opts)
  }
end

diff = CmdOptions.new 'diff', "Generates a change script from available patches"
apply_diff(diff) { |db, version_dir, output_dir, opts|
db.diff version_dir, output_dir, opts
}

upgrade = CmdOptions.new 'upgrade', "Uses the version table to generate a set of changes and apply them to database(s)"
apply_diff(upgrade) { |db, version_dir, output_dir, opts|
  db.upgrade version_dir, output_dir, opts
}

rollback = CmdOptions.new 'rollback', "Generates a rollback script and applies it to the database(s)"
apply_diff(rollback) { |db, version_dir, output_dir, opts|
  db.rollback version_dir, output_dir, opts
}

run = CmdOptions.new 'run', "Run sql provided from file(s) or from input stream"
run.db_conf_path
run.files_or_input
run.invoke = lambda { |opts|
  db=load_db ARGV.shift
  ARGV.each { |a|
    db.exec_script a
  }
}

CmdOptions.parse


