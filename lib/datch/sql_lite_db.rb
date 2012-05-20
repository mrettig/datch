module Datch

  require "socket"
  require 'date'

  class SqlLiteDb

    def initialize(db_file='datch.sqlite.db', init_sql_file=SqlLiteDb::default_init_sql)
      @db=db_file
      @init_db_sql = init_sql_file
    end

    def self.default_init_sql
      file = File.dirname(__FILE__) + "/init_sqlite_db.sql"
    end

    def init_db
      stmt = "sqlite3 -bail #@db <#@init_db_sql"
      unless system(stmt)
        raise "init db failed: #{stmt}"
      end
    end

    def create_version_update_sql(file)
      <<eod
insert into datch_version
    (file,version, host, user, timestamp)
values
  ('#{file.name}','#{file.version}', '#{Socket.gethostname}', '#{ENV['USER']}', '#{DateTime.now.to_s}');
eod
    end
  end
end