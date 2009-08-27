package EZ::360::Schema::Result::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_role");
__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "role_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-26 23:25:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sBZfbXf8ZL1iSDGFczmgZg

__PACKAGE__->belongs_to(
    user => 'EZ::360::Schema::Result::User', 'user_id'
);

__PACKAGE__->belongs_to(
    role => 'EZ::360::Schema::Result::Role', 'role_id'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
