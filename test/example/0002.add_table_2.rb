require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table two;"
  rollback="drop two;"
  SqlPatch.new change, rollback
end