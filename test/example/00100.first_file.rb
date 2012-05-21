require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table person(first_name text, last_name text);"
  rollback="drop table person;"
  SqlPatch.new change, rollback
end