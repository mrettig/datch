require 'erb'
require 'yaml'

module Datch

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

  attr_reader :file, :version_update_sql

  def initialize(datch_file, version_update_sql)
    @file=datch_file
    @version_update_sql=version_update_sql
  end

  def change
    @datch_file.change
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
    write(output+".changes.sql", 'changes.erb')
  end

  def write(file, template)
    changes=[]
    @entries.each {|e|
      changes << DatchModel.new(e, db.create_version_update_sql(e))
    }
    tmp_body=File.new("#@dir/#{template}").read
    template = ERB.new tmp_body
    output = template.result(binding)
    File.open(file, 'w') { |f|
      f.write output
    }
  end

  def write_rollback_sql(output)
    write(output+".rollback.sql", 'rollback.erb')
  end

end

end
