module Datch

  require "socket"
  require 'date'
  require 'tempfile'
  require File.dirname(__FILE__) + "/datch.rb"
  require 'set'

  class SqlplusDb

    def initialize(user, password, connect_id)
      @user=user
      @password=password
      @connect_id=connect_id
    end

    def file_id
      full= "#@user_#@connect_id"
      full.gsub! '/', '_'
      full.gsub! '\\', '_'
      full.gsub! ':', '_'
      full
    end

    def schema
      @user
    end

    def to_s
      "#@user@#@connect_id"
    end

    def init_db
      exec_sql "create table datch_version(schema_name varchar2(50) not null, version integer not null , file_name VARCHAR2(50) not null, host VARCHAR2(50), user_name VARCHAR2(50), change_timestamp TIMESTAMP, primary key(version, schema_name));"
    end

    def cleanup_db
      exec_sql "drop table datch_version;"
    end

    def exec_sql(sql)
      body=<<EOD
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
WHENEVER OSERROR EXIT 2 ROLLBACK;
#{sql}
EOD
      stmt="sqlplus -S -L #@user/#@password@#@connect_id <<EOF\n #{body} \nEOF"
      unless system(stmt)
          raise "sql failed: #{stmt}"
      end
    end

    def exec_script(script_path)
      stmt="sqlplus -S -L #@user/#@password@#@connect_id <#{script_path}"
      unless system(stmt)
        raise "sql failed: #{stmt}"
      end
    end

    def find_versions
      file = Tempfile.new('datch.sqlplus.query')
      to_file=<<eod
set HEADING OFF
set pagesize 0
set trimspool on
SPOOL #{file.path}
select version from datch_version where schema_name='#{schema}';
SPOOL OFF
eod
      set=SortedSet.new
      begin
        exec_sql to_file
        File.readlines(file.path).each{ |line|
          if line.strip.size > 0
            set << line.strip.to_i
          end
        }
      ensure
        file.unlink
      end
      set
    end

    def create_version_update_sql(file)
      "insert into datch_version (schema_name, file_name,version, host, user_name, change_timestamp) values ('#{schema}', '#{file.name}',#{file.version}, '#{Socket.gethostname}', '#{ENV['USER']}', sysdate);"
    end

    def create_version_rollback_sql(file)
      "delete from datch_version where version=#{file.version} and schema_name='#{schema}';"
    end


  end
end