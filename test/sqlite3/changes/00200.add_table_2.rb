require File.dirname(__FILE__) +"/../../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table address(street text, city text, zip text);"
  rollback="drop table address;"
  SqlPatch.new change, rollback
end