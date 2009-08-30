package EZ::360::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("user");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "username",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "password",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "email",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "realname",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-30 01:31:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:58RQ7u0lxcVZAzkb4iRLzg

__PACKAGE__->add_columns(
    password => {
        data_type     => 'TEXT',
        size          => undef,
        encode_column => 1,
        encode_class  => 'Digest',
        encode_args   => {
            algorithm   => 'SHA-1',
            format      => 'hex',
            salt_length => 10,
        },
        encode_check_method => 'check_password',
      },
);

__PACKAGE__->has_many(
    user_role => 'EZ::360::Schema::Result::UserRole', 'user_id'
);

__PACKAGE__->many_to_many(
    roles => 'user_role', 'role'
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
