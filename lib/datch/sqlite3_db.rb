module Datch

  require "socket"
  require 'date'
  require 'tempfile'
  require File.dirname(__FILE__) + "/datch.rb"

  class Sqlite3Db

    def initialize(db_file='datch.sqlite.db')
      @db=db_file
    end

    def init_db
      exec_sql "create table datch_version(version integer not null , file_name text not null, host text, user_name text, timestamp text, primary key(version));"
    end

    def exec_sql(sql)
      stmt="sqlite3 -bail #@db <<EOF\n #{sql} \nEOF"
      unless system(stmt)
          raise "sql failed: #{stmt}"
      end
    end

    def find_max_version
      file = Tempfile.new('datch.sqlite.query')
      to_file=<<eod

.mode list
.output #{file.path}
select max(version) from datch_version;
eod
      begin
        exec_sql to_file
        all = File.read(file.path)
        if all.size > 0
          return all.to_i
        end
      ensure
        file.unlink
      end
      0
    end

    def create_version_update_sql(file)
      "insert into datch_version (file_name,version, host, user_name, timestamp) values ('#{file.name}',#{file.version}, '#{Socket.gethostname}', '#{ENV['USER']}', '#{DateTime.now.to_s}');"
    end

    def create_version_rollback_sql(file)
      "delete from datch_version where version=#{file.version};"
    end

  end
end