requires 'perl'                  => '5.008001';
requires 'Class::Accessor::Lite' => '0.05';
requires 'Furl'                  => '2.19';
requires 'IO::Socket::SSL'       => '1.955';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
