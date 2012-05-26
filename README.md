datch
=====

database scripting and patching made easy

### Scripting

Datch provides a scriptable frontend to database command line tools.

```bash
$ ruby lib/datch/datch_main.rb run conf/dev_dbs <<EOF
select * from dual;
EOF
```

```bash
$ ruby lib/datch/datch_main.rb run conf/dev_dbs baseline/scripts/*.sql
```

### Versioning

Datch is based on creating simple database patch files in ruby. A single directory is used. The files within the directory are
 named with a version number, a descriptive name, and an .rb extension. Datch will use the version numbers to load, process, and create
 a change script based on the version numbers of the files. A database table in the target database tracks what changes have been applied.

### Directory Example

* 001.my_table.rb
* 002.other_table.rb
* changes.erb - ERB change template
* rollback.erb = ERB rollback template

### Example Datch

```ruby
require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table person(first_name text, last_name text);"
  rollback="drop table person;"
  SqlPatch.new change, rollback
end
```

### Running

##### $ ruby datch/datch_main.rb init_db my_db_conf.rb

This will generate the database schema for storing version information.

##### $ ruby datch/datch_main.rb diff my_db_conf.rb changes_dir output_file_name

This command generates a change and rollback script.