
class SqlLiteDb
  def init_db
    file = File.dirname(__FILE__) + "/init_db.sql"
    exec("sqlite3 -bail datch.sqlite.db <#{file}")
  end
end

def configure
    SqlLiteDb.new
end