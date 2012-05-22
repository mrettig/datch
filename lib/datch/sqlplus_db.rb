module Datch

  require "socket"
  require 'date'
  require 'tempfile'
  require File.dirname(__FILE__) + "/datch.rb"

  class SqlplusDb


    def initialize(user, password, connect_id)
      @user=user
      @password=password
      @connect_id=connect_id
    end

    def init_db
      exec_sql "create table datch_version(version integer not null , file_name VARCHAR2(50) not null, host VARCHAR2(50), user_name VARCHAR2(50), timestamp TIMESTAMP, primary key(version));"
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

    def find_max_version
      file = Tempfile.new('datch.sqlplus.query')
      to_file=<<eod
set HEADING OFF
set pagesize 0
set trimspool on
SPOOL #{file.path}
select max(version) from datch_version;
SPOOL OFF
eod
      begin
        exec_sql to_file
        all = File.read(file.path)
        if all.strip.size > 0
          return all.strip.to_i
        end
      ensure
        file.unlink
      end
      0
    end

    def create_version_update_sql(file)
      "insert into datch_version (file_name,version, host, user_name, timestamp) values ('#{file.name}',#{file.version}, '#{Socket.gethostname}', '#{ENV['USER']}', sysdate);"
    end

    def create_version_rollback_sql(file)
      "delete from datch_version where version=#{file.version};"
    end


  end
end