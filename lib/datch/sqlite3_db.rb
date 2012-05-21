module Datch

  require "socket"
  require 'date'
  require 'tempfile'
  require File.dirname(__FILE__) + "/datch.rb"
  require 'set'

  class Sqlite3Db

    def initialize(db_file='datch.sqlite.db')
      @db=db_file
    end

    def init_db
      init_sql="create table datch_version(version integer not null , file text not null, host text, user text, timestamp text, primary key(version));"
      stmt = "sqlite3 -bail #@db <<EOF\n #{init_sql} \nEOF"
      unless system(stmt)
        raise "init db failed: #{stmt}"
      end
    end

    def load_prior_versions
      file = Tempfile.new('datch.sqlite.query')
      to_file=<<eod

.headers ON
.mode list
.output #{file.path}

select file, version from datch_version;

eod
      keys = Set.new
      begin
        stmt="sqlite3 -bail #@db <<EOF #{to_file} \nEOF"
        unless system(stmt)
          raise "query failed: #{stmt}"
        end
        all = File.readlines(file.path)
        if all.size > 0
          header = all.shift.strip.split('|')
          version_idx = header.find_index('version')
          file_idx = header.find_index('file')
          all.each { |line|
            parts = line.strip.split('|')
            keys << Datch::Key.parse(parts[file_idx], parts[version_idx])
          }
        end
      ensure
        file.unlink
      end
      keys
    end

    def create_version_update_sql(file)
      "insert into datch_version (file,version, host, user, timestamp) values ('#{file.name}',#{file.version}, '#{Socket.gethostname}', '#{ENV['USER']}', '#{DateTime.now.to_s}');"
    end

    def create_version_rollback_sql(file)
      "delete from datch_version where file='#{file.name}' and version=#{file.version};"
    end

  end
end