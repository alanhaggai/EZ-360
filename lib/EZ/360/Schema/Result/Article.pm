package EZ::360::Schema::Result::Article;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("article");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "title",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "content",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "created",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "updated",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("title_unique", ["title"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-26 23:54:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7cMPpATV0QD3v5EFjR/TVw

__PACKAGE__->add_columns(
    created => {
        data_type     => 'datetime',
        set_on_create => 1,
    },
    updated => {
        data_type     => 'datetime',
        set_on_create => 1,
        set_on_update => 1,
    },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
