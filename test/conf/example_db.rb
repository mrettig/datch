
class SqlLiteDb
  def init_db
    file = File.dirname(__FILE__) + "/init_db.sql"
    stmt = "sqlite3 -bail datch.sqlite.db <#{file}"
    unless system(stmt)
      raise "init db failed: #{stmt}"
    end
  end
end

def configure
    SqlLiteDb.new
end