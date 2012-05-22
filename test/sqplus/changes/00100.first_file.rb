require File.dirname(__FILE__) +"/../../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table person(first_name varchar2(50), last_name varchar2(50));"
  rollback="drop table person;"
  SqlPatch.new change, rollback
end