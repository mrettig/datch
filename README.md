datch
=====

database scripting and patching made easy

### Database Configuration
Database configurations are created in ruby. The configuration can return a single database config or multiple. Scripting commands
are designed to operate on any number of databases.

```ruby
require File.dirname(__FILE__) + "datch/sqlite3_db.rb"

def configure
    [Datch::Sqlite3Db.new('sqlite3.1.db'),Datch::Sqlite3Db.new('sqlite3.2.db')]
end
```

### Scripting

Datch provides a scriptable frontend to database command line tools.

```bash
$ ruby datch/datch_main.rb run conf/dev_dbs baseline/scripts/*.sql
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

```bash
$ ruby datch/datch_main.rb
```

This will display the available commands and options.