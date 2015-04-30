use strict;
use Test::More 0.98;
use JSON::XS;
use HTTP::Request;
use Data::Dumper;

use_ok('Yandex::OAuth::Client');

my  $client = Yandex::OAuth::Client->new(
        token => '************', 
        endpoint => 'https://api-metrika.yandex.ru/'
    );

is( $client->make_url(['stat','test']), 'https://api-metrika.yandex.ru/stat/test', 'make_url' );
is( $client->make_url(['stat','test'], {pretty => 1}), 'https://api-metrika.yandex.ru/stat/test?pretty=1', 'make_url query param' );
is( $client->make_url('https://api-metrika.yandex.ru/stat/test?pretty=1'), 'https://api-metrika.yandex.ru/stat/test?pretty=1', 'make_url clean url' );

my $req = HTTP::Request->new( uc 'get' => $client->make_url(['stat','test'], {pretty => 1}) );

$client->prepare_request($req);

is( $req->header('content-type'), 'application/json; charset=UTF-8', 'prepare_request type');
is( $req->header('content-length'), 0, 'prepare_request zero length');
is( $req->header('authorization'), 'Bearer ************', 'prepare_request auth');

$client->prepare_request($req, { param1 => 'value1', param2 => 2});

is( $req->header('content-length'), 30, 'prepare_request length');
is( $req->content, '{"param2":2,"param1":"value1"}', 'prepare_request body');

my $answer = '{"param2":2,"param1":"value1"}';
is_deeply($client->parse_response($answer), JSON::XS::decode_json($answer), 'parse_response');

$answer = '';
is( $client->parse_response($answer), undef, 'parse_response');

done_testing;
