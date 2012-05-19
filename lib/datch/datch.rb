require 'erb'
dir=ARGV.shift
output=ARGV.shift

class DatchFile
  attr_reader :patch, :name, :version
  include Comparable

  def initialize(f, context)
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
    @patch = DatchFile::load_file(f, context)
  end

  def self.load_file(f, context)
    load f
    datch(context)
  end

  def <=>(other)
    result = version <=>other.version
    result != 0 ? result : name <=> other.name
  end
end

class DatchParser
  def initialize(dir)
    @entries = []
    @dir = dir

    Dir.glob("#{dir}/*.rb") { |f|
      @entries << DatchFile.new(f, self)
    }
    @entries.sort!
  end

  def write_change_sql(output)
    write(output+".changes.sql") { |e| e.patch.change }
  end

  def write(file, &cb)
    changes=[]
    @entries.each { |e| changes << cb.call(e) }
    tmp_body=File.new("#@dir/changes.erb").read
    template = ERB.new tmp_body
    output = template.result(binding)
    File.open(file, 'w') { |f|
      f.write output
    }
  end

  def write_rollback_sql(output)
    write(output+".rollback.sql") { |e| e.patch.rollback }
  end

end

parser = DatchParser.new(dir)
parser.write_change_sql(output)
parser.write_rollback_sql(output)