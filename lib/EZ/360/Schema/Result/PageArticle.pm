package EZ::360::Schema::Result::PageArticle;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("page_article");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "page_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "article_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-10-26 23:54:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GXGkMmne3d8REAw4L08XmA

__PACKAGE__->has_one(
    article => 'EZ::360::Schema::Result::Article',
    { 'foreign.id' => 'self.article_id' }
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
