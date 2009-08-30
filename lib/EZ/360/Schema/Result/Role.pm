package EZ::360::Schema::Result::Role;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("role");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "role",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-30 01:31:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SHzMUWcwZWAr1RmDynVtCg

__PACKAGE__->has_many(
    user_role => 'EZ::360::Schema::Result::UserRole', 'role_id' 
);

__PACKAGE__->many_to_many(
    users => 'user_role', 'user'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
