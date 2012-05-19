require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table one;"
  rollback="drop one;"
  SqlPatch.new change, rollback
end