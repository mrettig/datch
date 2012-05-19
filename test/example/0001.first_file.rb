require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(parser)
  change="create table blah"
  SqlPatch.new change
end