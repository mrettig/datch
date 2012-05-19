dir=ARGV.shift
output=ARGV.shift

class DatchFile
  attr_reader :patch

  def initialize(f, context)
    load f
    @patch = datch(context)
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