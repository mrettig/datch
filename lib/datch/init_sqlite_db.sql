create table datch_version(version text not null , file text not null,
  host text, user text, timestamp text,
  primary key(version, file));
