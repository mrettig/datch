require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change=<<eod
insert into person(first_name, last_name) values ('joe', 'smith');
eod
  SqlPatch.new change
end