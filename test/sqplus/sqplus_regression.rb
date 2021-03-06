require File.dirname(__FILE__) + "/../../lib/datch/sqlplus_db.rb"
require File.dirname(__FILE__) + "/../../lib/datch/datch.rb"

require 'tempfile'

def run(*max_versions)
  version_dir = File.dirname(__FILE__) + '/changes'

  db=Datch::SqlplusDb.new('scott', 'tiger', 'localhost:1521/sample')
  temp_dirs=[]
  begin
    db.init_db
    max_versions.each { |m|
      puts "Starting run: #{m} from #{max_versions.inspect}"
      temp_dir= Dir.mktmpdir
      temp_dirs << temp_dir
      version_set = Datch::VersionSet.new db.find_versions, false, :max_version=>m
      Datch::DatchParser.write_diff(version_dir, db, temp_dir, version_set)
      db.exec_script(temp_dir+"/changes.sql")
    }
    temp_dirs.reverse.each {|d|
      db.exec_script d + "/rollback.sql"
    }
  ensure
    db.cleanup_db
    temp_dirs.each { |d|
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



