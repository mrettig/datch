require File.dirname(__FILE__) + "/../../../lib/datch/sqlite3_db.rb"

def configure
    [Datch::Sqlite3Db.new('sqlite3.1.db'),Datch::Sqlite3Db.new('sqlite3.2.db')]
end