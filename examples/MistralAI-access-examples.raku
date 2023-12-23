#!/usr/bin/env raku
use v6.d;

use lib '.';

use WWW::MistralAI;

#say mistralai-playground("What is the min speed of a rocket leaving Earh?", format => Whatever, max-tokens => 900);

#say mistralai-playground("What is the min speed of a rocket leaving Earh?", format => Whatever, max-tokens => 900);

say '=' x 120;

my @models = |mistralai-playground(path => 'models');

*<id>.say for @models;

say '-' x 120;

say mistralai-playground(path => 'models', format => 'values');

say '=' x 120;

#say mistralai-embeddings('hello world'.words);