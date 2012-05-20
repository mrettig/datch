require "socket"
require 'date'

class SqlLiteDb
  def init_db
    file = File.dirname(__FILE__) + "/init_db.sql"
    stmt = "sqlite3 -bail datch.sqlite.db <#{file}"
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

def configure
    SqlLiteDb.new
end