require File.dirname(__FILE__) +"/../../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table address(street varchar2(50), city varchar2(50), zip varchar2(50));"
  rollback="drop table address;"
  SqlPatch.new change, rollback
end