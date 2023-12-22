#!/usr/bin/env raku
use v6.d;

use lib '.';

use WWW::MistralAI;

#say mistralai-playground("What is the min speed of a rocket leaving Earh?", format => Whatever, max-tokens => 900);

#say mistralai-playground("What is the min speed of a rocket leaving Earh?", format => Whatever, max-tokens => 900);

#say mistralai-playground('', path=>'models');

say mistralai-embeddings('hello world'.words);