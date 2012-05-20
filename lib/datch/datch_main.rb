require File.dirname(__FILE__) + "/datch.rb"

dir=ARGV.shift
output=ARGV.shift
load ARGV.shift
db=configure

parser = DatchParser.new(dir, db)
parser.write_change_sql(output)
parser.write_rollback_sql(output)