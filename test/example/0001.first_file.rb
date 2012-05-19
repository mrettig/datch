require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table blah"
  rollback="rollback blah"
  SqlPatch.new change, rollback
end