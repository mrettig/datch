require 'erb'
require 'yaml'
require 'ostruct'

module Datch

class VersionSet
  def initialize(set, rollback, opts={})
    @set = set
    @max = opts[:max_version]
    @min = opts[:min_version]
    @rollback=rollback
  end

  def valid?(datch_file)
    v = datch_file.version
    if @max && v > @max
      false
    elsif @min && v <= @min
      false
    else
      if @rollback
        @set.include? v
      else
        !@set.include? v
      end
    end
  end
end

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

  def initialize(dir, db, diff_strategy)
    @entries = []
    @dir = dir
    @db = db
    all_versions=[]
    Dir.glob("#{dir}/*.rb") { |f|
      datch_file = DatchFile.new(f, self)

      raise "duplicate version found #{datch_file.version}" if all_versions.include?(datch_file.version)

      all_versions << datch_file.version

      if diff_strategy.valid? datch_file
        @entries << datch_file
        puts "valid #{datch_file.name}"
      end
    }
    @entries.sort!
  end

  def self.write_diff(version_dir, db, output_dir, diff_strategy)
    parser = Datch::DatchParser.new(version_dir, db, diff_strategy)
    parser.write_change_sql(output_dir)
    parser.write_rollback_sql(output_dir)
  end

  def write_change_sql(output_dir)
    FileUtils.mkdir_p output_dir
    write(output_dir+"/changes.sql", 'changes.erb')
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
    write(output+"/rollback.sql", 'rollback.erb')
  end

end

  class DbArray
    def initialize(dbs)
      @dbs = [*dbs]
    end

    def init_db
      @dbs.each { |d| d.init_db}
    end

    def exec_sql(sql)
      @dbs.each { |d|
        puts d
        d.exec_sql(sql)
      }
    end

    def diff(version_dir, output_dir, opts={})
    @dbs.each{ |db|
      version_set = Datch::VersionSet.new db.find_versions, false, opts
      full_dir="#{output_dir}/#{db.file_id}"
      Datch::DatchParser.write_diff(version_dir, db, full_dir, version_set)
    }
    end

    def upgrade(version_dir, output_dir, opts={})
      @dbs.each{ |db|
        version_set = Datch::VersionSet.new db.find_versions, false, opts
        full_dir="#{output_dir}/#{db.file_id}"
        Datch::DatchParser.write_diff(version_dir, db, full_dir, version_set)
        db.exec_script "/#{full_dir}/changes.sql"
      }
    end

    def rollback(version_dir, output_dir, opts={})
      @dbs.each{ |db|
        version_set = Datch::VersionSet.new db.find_versions, true, opts
        full_dir="#{output_dir}/#{db.file_id}"
        Datch::DatchParser.write_diff(version_dir, db, full_dir, version_set)
        db.exec_script "/#{full_dir}/rollback.sql"
      }
    end
  end

end
