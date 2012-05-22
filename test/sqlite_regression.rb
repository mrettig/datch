require File.dirname(__FILE__) + "/../lib/datch/sqlite3_db.rb"
require File.dirname(__FILE__) + "/../lib/datch/datch.rb"

require 'tempfile'

def run(*max_versions)
  file = Tempfile.new('datch.sqlite.regression')
  temp_dir= Dir.mktmpdir
  change_prefix=temp_dir +'/example'
  version_dir = File.dirname(__FILE__) + '/example'

  begin
    db=Datch::Sqlite3Db.new(file.path)
    db.init_db
    max_versions.each { |m|
      Datch::DatchParser.write_diff(version_dir, db, change_prefix, m)
      unless system("sqlite3 -bail #{file.path} <#{change_prefix+".changes.sql"}")
        raise "failed"
      end
    }
    unless system("sqlite3 -bail #{file.path} <#{change_prefix+".rollback.sql"}")
      raise "failed"
    end
  ensure
    file.unlink # deletes the temp file
    FileUtils.remove_entry_secure temp_dir
  end
end

run 100
run 100, 101
run 101
run 100, 101, 200
run 200
run 99999999999



