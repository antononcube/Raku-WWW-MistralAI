unit module WWW::MistralAI;

use JSON::Fast;
use HTTP::Tiny;

use WWW::MistralAI::ChatCompletions;
use WWW::MistralAI::Embeddings;
use WWW::MistralAI::Models;
use WWW::MistralAI::Request;

#===========================================================
#| Gives the base URL of OpenAI's endpoints.
our sub mistralai-base-url(-->Str) is export { return 'https://api.mistral.ai/v1';}


#===========================================================
#| MistralAI chat completions access. (Synonym of mistralai-chat-completion.)
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$stream> -- whether to stream the result or not;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
sub mistralai-completion(**@args, *%args) is export {
   return mistralai-chat-completion(|@args, |%args);
}


#===========================================================
#| MistralAI chat completions access.
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$stream> -- whether to stream the result or not;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto mistralai-chat-completion(|) is export {*}

multi sub mistralai-chat-completion(**@args, *%args) {
    return WWW::MistralAI::ChatCompletions::MistralAIChatCompletion(|@args, |%args);
}

#===========================================================
#| MistralAI embeddings access.
#| C<$prompt> -- prompt to make embeddings for;
#| C<:$model> -- model;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto mistralai-embeddings(|) is export {*}

multi sub mistralai-embeddings(**@args, *%args) {
    return WWW::MistralAI::Embeddings::MistralAIEmbeddings(|@args, |%args);
}

#===========================================================
#| MistralAI models access.
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout.
our proto mistralai-models(|) is export {*}

multi sub mistralai-models(*%args) {
    return WWW::MistralAI::Models::MistralAIModels(|%args);
}

#============================================================
# Playground
#============================================================

#| MistralAI playground access.
#| C<:path> -- end point path;
#| C<:api-key(:$auth-key)> -- authorization key (API key);
#| C<:timeout> -- timeout
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>,
#| C<*%args> -- additional arguments, see C<mistralai-chat-completion> and C<mistralai-text-completion>.
our proto mistralai-playground($text is copy = '',
                               Str :$path = 'completions',
                               :api-key(:$auth-key) is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny',
                               Str :$base-url = 'https://api.mistral.ai/v1',
                               *%args
                               ) is export {*}

#| MistralAI playground access.
multi sub mistralai-playground(*%args) {
    return mistralai-playground('', |%args);
}

#| MistralAI playground access.
multi sub mistralai-playground(@texts, *%args) {
    return @texts.map({ mistralai-playground($_, |%args) });
}

#| MistralAI playground access.
multi sub mistralai-playground($text is copy,
                               Str :$path = 'completions',
                               :api-key(:$auth-key) is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny',
                               Str :$base-url = 'https://api.mistral.ai/v1',
                               *%args
                               ) {

    #------------------------------------------------------
    # Dispatch
    #------------------------------------------------------
    given $path.lc {
        when $_ eq 'models' {
            # my $url = 'https://api.mistral.ai/v1/models';
            return mistralai-models(:$auth-key, :$timeout, :$method, :$base-url);
        }
        when $_ ∈ <completion completions chat/completions> {
            # my $url = 'https://api.mistral.ai/v1/chat/completions';
            my $expectedKeys = <model prompt max-tokens temperature top-p stream echo random-seed>;
            return mistralai-chat-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        when $_ ∈ <embedding embeddings> {
            # my $url = 'https://api.mistral.ai/v1/embeddings';
            return mistralai-embeddings($text,
                    |%args.grep({ $_.key ∈ <model encoding-format> }).Hash,
                    :$auth-key, :$timeout, :$format, :$method, :$base-url);
        }
        default {
            die 'Do not know how to process the given path.';
        }
    }
}