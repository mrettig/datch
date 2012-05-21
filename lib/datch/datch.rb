require 'erb'
require 'yaml'

module Datch

class Key
  include Comparable
  attr_accessor :name, :version
  def initialize(name, version)
    @name = name
    @version = version
  end

  def hash
    @name.hash + @version.hash
  end

  def eql?(other)
    (self <=> other) == 0
  end

  def name_str
    @name.join('.')
  end

  def version_str
    @version.join('.')
  end

  def self.parse(name_str, version_str)
    Key.new(name_str.split('.'), version_str.split('.').map{|s|s.to_i} )
  end

  def <=>(other)
    result = version <=>other.version
    result != 0 ? result : name <=> other.name
  end
end

class DatchFile
  attr_reader :patch, :path , :key
  include Comparable

  def initialize(f, context)
    @path = f
    parts = File.basename(f).split(".")
    version = []
    name = []
    version_check=true
    parts.each { |p|
      if version_check && p.match(/\A[0-9]+\Z/)
        version << p.to_i
      else
        name << p
        version_check=false
      end
    }
    @patch = DatchFile::load_file(f, context)
    raise "Invalid version #{version.inspect} from #{f}" unless version.size == 1
    @key= Key.new(name, version)
  end

  def name
    @key.name_str
  end

  def version
    @key.version_str
  end

  def self.load_file(f, context)
    load f
    datch(context)
  end

  def <=>(other)
    key <=> other.key
  end
end

class DatchModel

  attr_reader :file, :version_update_sql, :version_rollback_sql

  def initialize(datch_file, version_update_sql, version_rollback_sql)
    @file=datch_file
    @version_update_sql=version_update_sql
    @version_rollback_sql=version_rollback_sql
  end
end

class DatchParser

  attr_reader :db

  def initialize(dir, db, prior_entry_set=[], max_version=nil)
    @entries = []
    @dir = dir
    @db = db
    all_versions=[]
    Dir.glob("#{dir}/*.rb") { |f|
      datch_file = DatchFile.new(f, self)

      raise "duplicate version found #{datch_file.version}" if all_versions.include?(datch_file.version)

      all_versions << datch_file.version

      if (max_version.nil? || datch_file.key < max_version) && !prior_entry_set.include?(datch_file.key)
        @entries << datch_file
      end
    }
    @entries.sort!
  end

  def write_change_sql(output)
    write(output+".changes.sql", 'changes.erb')
  end

  def write(file, template)
    changes=[]
    @entries.each {|e|
      changes << DatchModel.new(e, db.create_version_update_sql(e), db.create_version_rollback_sql(e))
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
