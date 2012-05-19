dir=ARGV.shift
output=ARGV.shift

class DatchFile
  attr_reader :patch, :name, :version
  include Comparable

  def initialize(f, context)
    load f
    parts = File.basename(f).split(".")
    @versions = []
    @name = []
    parts.each { |p|
      if p.match /\A[0-9]+\Z/
        @versions << p.to_i
      else
        @name << p
      end
    }
    @patch = datch(context)
  end

  def <=>(other)
    result = version <=>other.version
    result != 0 ? result : name <=> other.name
  end
end

class DatchParser
  def initialize(dir)
    @entries = []
    puts dir
    puts `pwd`
    Dir.glob("#{dir}/*.rb") { |f|
      puts f
      @entries << DatchFile.new(f, self)
    }
    @entries.sort!
    puts @entries.inspect
  end

  def write_change_sql(output)
    write(output+".changes.sql") { |e| e.patch.change }
  end

  def write(file, &cb)
    File.open(file, 'w') { |f|
      f.puts "header"
      @entries.each { |e| f.puts cb.call(e) }
      f.puts "footer"
    }
  end

  def write_rollback_sql(output)
    write(output+".rollback.sql") { |e| e.patch.rollback }
  end

end

parser = DatchParser.new(dir)
parser.write_change_sql(output)
parser.write_rollback_sql(output)