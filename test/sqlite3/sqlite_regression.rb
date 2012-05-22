require File.dirname(__FILE__) + "/../../lib/datch/sqlite3_db.rb"
require File.dirname(__FILE__) + "/../../lib/datch/datch.rb"

require 'tempfile'

def run(*max_versions)
  file = Tempfile.new('datch.sqlite.regression')
  version_dir = File.dirname(__FILE__) + '/changes'
  temp_dirs = []
  begin
    db=Datch::Sqlite3Db.new(file.path)
    db.init_db
    max_versions.each { |m|
      temp_dir= Dir.mktmpdir
      temp_dirs << temp_dir
      change_prefix=temp_dir +'/example'
      Datch::DatchParser.write_diff(version_dir, db, change_prefix, m)
      db.exec_script change_prefix+".changes.sql"
    }
    temp_dirs.reverse.each{|d|
      db.exec_script d+"/example.rollback.sql"
    }
  ensure
    file.unlink # deletes the temp file
    temp_dirs.each{|d|
      FileUtils.remove_entry_secure d
    }
  end
end

run 100
run 100, 101
run 101
run 100, 101, 200
run 200
run 99999999999



