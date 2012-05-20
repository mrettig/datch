require File.dirname(__FILE__) + "/../lib/datch/sql_lite_db.rb"
require File.dirname(__FILE__) + "/../lib/datch/datch.rb"

require 'tempfile'

file = Tempfile.new('datch.sqlite.regression')
begin
  db=Datch::SqlLiteDb.new(file.path)
  db.init_db
  version_dir = File.dirname(__FILE__) + '/example'
  parser = Datch::DatchParser.new(version_dir, db)
  parser.write_change_sql 'example'
  parser.write_rollback_sql 'example'
ensure
   file.unlink   # deletes the temp file
end



