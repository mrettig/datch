require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change=<<eod
alter table one;
add index table one;
insert into table one values;
--other stuff;
eod
  SqlPatch.new change
end