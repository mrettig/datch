require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change="alter table one"
  SqlPatch.new change
end