module Datch

  require "socket"
  require 'date'
  require 'tempfile'
  require File.dirname(__FILE__) + "/datch.rb"
  require 'set'

  class Sqlite3Db

    def initialize(db_file='datch.sqlite.db')
      @db=File.expand_path(db_file)
    end

    def file_id
      @db
    end

    def init_db
      exec_sql "create table datch_version(schema_name text not null, version integer not null , file_name text not null, host text, user_name text, change_timestamp text, primary key(schema_name, version));"
    end

    def template_path(name)
      File.dirname(__FILE__) +"/sqlite3.#{name}.erb"
    end

    def to_s
      @db
    end

    def exec_sql(sql)
      stmt="sqlite3 -bail #@db <<EOF\n #{sql} \nEOF"
      unless system(stmt)
          raise "sql failed: #{stmt}"
      end
    end

    def exec_script(script_path)
      unless system("sqlite3 -bail #@db <#{script_path}")
        raise " #{script_path} failed"
      end
    end

    def valid?(datch_file)
      true
    end

    def find_versions
      file = Tempfile.new('datch.sqlite.query')
      to_file=<<eod

.mode list
.output #{file.path}
select version from datch_version where schema_name='#@db';
eod
      result = SortedSet.new
      begin
        exec_sql to_file
        File.readlines(file.path).each {|line|
          trimmed = line.strip
          if trimmed.size > 0
             result << trimmed.to_i
          end
        }
      ensure
        file.unlink
      end
      result
    end

    def create_version_update_sql(file)
      "insert into datch_version (schema_name, file_name,version, host, user_name, change_timestamp) values ('#@db', '#{file.name}',#{file.version}, '#{Socket.gethostname}', '#{ENV['USER']}', '#{DateTime.now.to_s}');"
    end

    def create_version_rollback_sql(file)
      "delete from datch_version where version=#{file.version} and schema_name='#@db';"
    end

  end
end