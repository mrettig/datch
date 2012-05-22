datch
=====

database patching made easy

### Versioning

Datch is based on creating simple database patch files in ruby. A single directory is used. The files within the directory are
 named with a version number, a descriptive name, and an .rb extension. Datch will use the version numbers to load, process, and create
 a change script based on the version numbers of the files. A database table in the target database tracks what changes have been applied.


### Example Datch

```ruby
require File.dirname(__FILE__) +"/../../lib/datch/sql_patch.rb"

def datch(context)
  change="create table person(first_name text, last_name text);"
  rollback="drop table person;"
  SqlPatch.new change, rollback
end
```