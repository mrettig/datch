require 'erb'
require 'yaml'
require 'ostruct'

module Datch

class DatchFile
  attr_reader :patch, :path , :name, :version
  include Comparable

  def initialize(f, context)
    @path = f
    parts = File.basename(f).split(".")
    @version = parts.shift.to_i
    @name = parts.join('.')
    @patch = DatchFile::load_file(f, context)
  end

  def self.load_file(f, context)
    load f
    datch(context)
  end

  def <=>(other)
    version <=> other.version
  end
end

class DatchParser

  attr_reader :db

  def initialize(dir, db, min_version, max_version=nil)
    @entries = []
    @dir = dir
    @db = db
    all_versions=[]
    Dir.glob("#{dir}/*.rb") { |f|
      datch_file = DatchFile.new(f, self)

      raise "duplicate version found #{datch_file.version}" if all_versions.include?(datch_file.version)

      all_versions << datch_file.version

      if (max_version.nil? || datch_file.version <= max_version) && datch_file.version > min_version
        @entries << datch_file
      end
    }
    @entries.sort!
  end

  def self.write_diff(version_dir, db, file_prefix, max_version=nil)
    max = db.find_max_version
    parser = Datch::DatchParser.new(version_dir, db, max, max_version)
    parser.write_change_sql(file_prefix)
    parser.write_rollback_sql(file_prefix)
  end

  def write_change_sql(output)
    write(output+".changes.sql", 'changes.erb')
  end

  def write(file, template)
    changes=[]
    @entries.each {|e|
      model = OpenStruct.new
      model.file=e
      model.version_update_sql=db.create_version_update_sql(e)
      model.version_rollback_sql=db.create_version_rollback_sql(e)
      changes << model
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
