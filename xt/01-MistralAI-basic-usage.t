use v6.d;

use lib '.';
use lib './lib';

use WWW::MistralAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok mistralai-playground(path => 'models', :$method);

## 2
ok mistralai-playground('What is the most important word in English today?', :$method);

## 3
ok mistralai-playground('Generate Raku code for a loop over a list', path => 'completions', type => Whatever, model => Whatever, :$method);

## 4
ok mistralai-playground('Generate Raku code for a loop over a list', path => 'chat/completions', model => 'mist', :$method);

done-testing;
