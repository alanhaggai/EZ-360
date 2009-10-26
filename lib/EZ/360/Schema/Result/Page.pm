package EZ::360::Schema::Result::Page;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("page");
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
  "main",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("title_unique", ["title"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-26 23:54:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vX1rzmMKH0TyRYbPRdUCvA

__PACKAGE__->has_many(
    children => 'EZ::360::Schema::Result::PageRelation',
    'page_id'
);

__PACKAGE__->has_many(
    articles => 'EZ::360::Schema::Result::PageArticle',
    'page_id'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
