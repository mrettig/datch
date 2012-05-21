require File.dirname(__FILE__) + "/../lib/datch/sqlite3_db.rb"
require File.dirname(__FILE__) + "/../lib/datch/datch.rb"

require 'tempfile'

file = Tempfile.new('datch.sqlite.regression')
temp_dir= Dir.mktmpdir
begin
  db=Datch::Sqlite3Db.new(file.path)
  db.init_db
  version_dir = File.dirname(__FILE__) + '/example'
  max = db.find_max_version
  puts max
  parser = Datch::DatchParser.new(version_dir, db, max)
  change_prefix=temp_dir +'/example'
  parser.write_change_sql(change_prefix)
  parser.write_rollback_sql(change_prefix)
  unless system("sqlite3 -bail #{file.path} <#{change_prefix+".changes.sql"}")
    raise "failed"
  end
  unless system("sqlite3 -bail #{file.path} <#{change_prefix+".rollback.sql"}")
    raise "failed"
  end

ensure
   file.unlink   # deletes the temp file
   FileUtils.remove_entry_secure temp_dir
end



