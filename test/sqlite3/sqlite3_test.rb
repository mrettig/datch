require "test/unit"

require File.dirname(__FILE__) + "/../../lib/datch/sqlite3_db.rb"
require File.dirname(__FILE__) + "/../../lib/datch/datch.rb"

require 'tempfile'

class Sqlite3Test < Test::Unit::TestCase

  def setup
    @db_file = Tempfile.new('datch.sqlite.test')
    @version_dir = File.dirname(__FILE__) + '/changes'
    @temp_dir= Dir.mktmpdir
    @db=Datch::DbArray.new(Datch::Sqlite3Db.new(@db_file.path))
    @db.init_db
  end

  def teardown
    @db_file.unlink # deletes the temp file
    FileUtils.remove_entry_secure @temp_dir
  end

  def test_full_upgrade
    @db.upgrade @version_dir , @temp_dir
    @db.rollback @version_dir , @temp_dir
  end
end