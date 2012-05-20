require File.dirname(__FILE__) + "/datch.rb"

dir=ARGV.shift
output=ARGV.shift
conf = YAML.load_file ARGV.shift

parser = DatchParser.new(dir, conf)
parser.write_change_sql(output)
parser.write_rollback_sql(output)