
class SqlLiteDb
  def init_db
    file = File.dirname(__FILE__) + "/init_db.sql"
    exec('sqlite3', '-bail', '-init', file)
  end
end

def configure
    SqlLiteDb.new
end