use v6.d;

use WWW::MistralAI::Models;
use WWW::MistralAI::Request;
use JSON::Fast;
use MIME::Base64;
use Image::Markup::Utilities;

unit module WWW::MistralAI::ChatCompletions;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);


#============================================================
# Completions
#============================================================

# In order to understand the design of [role => message,] argument see:
# https://docs.mistral.ai/api/#operation/createChatCompletion


#| MistralAI completion access.
our proto MistralAIChatCompletion($prompt is copy,
                                  :$role is copy = Whatever,
                                  :$model is copy = Whatever,
                                  :$temperature is copy = Whatever,
                                  :$max-tokens is copy = Whatever,
                                  Numeric :$top-p = 1,
                                  Bool :$stream = False,
                                  :api-key(:$auth-key) is copy = Whatever,
                                  UInt :$timeout= 10,
                                  :$format is copy = Whatever,
                                  Str :$method = 'tiny') is export {*}

#| MistralAI completion access.
multi sub MistralAIChatCompletion(Str $prompt, *%args) {
    return MistralAIChatCompletion([$prompt,], |%args);
}

#| MistralAI completion access.
multi sub MistralAIChatCompletion(@prompts is copy,
                                  :$role is copy = Whatever,
                                  :$model is copy = Whatever,
                                  :$temperature is copy = Whatever,
                                  :$max-tokens is copy = Whatever,
                                  Numeric :$top-p = 1,
                                  Bool :$stream = False,
                                  :api-key(:$auth-key) is copy = Whatever,
                                  UInt :$timeout= 10,
                                  :$format is copy = Whatever,
                                  Str :$method = 'tiny') {

    #------------------------------------------------------
    # Process $role
    #------------------------------------------------------
    if $role.isa(Whatever) { $role = "user"; }
    die "The argument \$role is expected to be Whatever or one of the strings: { '"' ~ $knownRoles.keys.sort.join('", "') ~ '"' }."
    unless $role ∈ $knownRoles;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'mistral-tiny'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ mistralai-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ mistralai-known-models;

    #------------------------------------------------------
    # Process $temperature
    #------------------------------------------------------
    if $temperature.isa(Whatever) { $temperature = 0.7; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 2."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 1;

    #------------------------------------------------------
    # Process $max-tokens
    #------------------------------------------------------
    if $max-tokens.isa(Whatever) { $max-tokens = 16; }
    die "The argument \$max-tokens is expected to be Whatever or a positive integer."
    unless $max-tokens ~~ Int && 0 < $max-tokens;

    #------------------------------------------------------
    # Process $top-p
    #------------------------------------------------------
    if $top-p.isa(Whatever) { $top-p = 1.0; }
    die "The argument \$top-p is expected to be Whatever or number between 0 and 1."
    unless $top-p ~~ Numeric && 0 ≤ $top-p ≤ 1;

    #------------------------------------------------------
    # Process $stream
    #------------------------------------------------------
    die "The argument \$stream is expected to be Boolean."
    unless $stream ~~ Bool;

    #------------------------------------------------------
    # Messages
    #------------------------------------------------------
    my @messages = @prompts.map({
        if $_ ~~ Pair {
            %(role => $_.key, content => $_.value)
        } else {
            %(:$role, content => $_)
        }
    });

    #------------------------------------------------------
    # Make MistralAI URL
    #------------------------------------------------------

    my %body = :$model, :$temperature, :$stream,
               top_p => $top-p,
               :@messages,
               max_tokens => $max-tokens;

    my $url = 'https://api.mistral.ai/v1/chat/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return mistralai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
