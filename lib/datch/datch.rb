require 'erb'
require 'yaml'

class DatchFile
  attr_reader :patch, :path
  include Comparable

  def initialize(f, context)
    @path = f
    parts = File.basename(f).split(".")
    @version = []
    @name = []
    version_check=true
    parts.each { |p|
      if version_check && p.match(/\A[0-9]+\Z/)
        @version << p.to_i
      else
        @name << p
        version_check=false
      end
    }
    @patch = DatchFile::load_file(f, context)
  end

  def name
    @name.join('.')
  end

  def version
    @version.join('.')
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

class DatchModel

  attr_reader :sql, :file

  def initialize(datch_file, sql)
    @sql = sql
    @file=datch_file
  end

  def version_update_sql
    "insert into datch_version(file,version) values('#{file.name}','#{file.version}');"
  end

  def to_s
    @sql
  end
end

class DatchParser

  attr_reader :db

  def initialize(dir, db)
    @entries = []
    @dir = dir
    @db = db

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
    @entries.each { |e|
      sql = cb.call(e)
      if sql
        changes << DatchModel.new(e, sql)
      end
    }
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