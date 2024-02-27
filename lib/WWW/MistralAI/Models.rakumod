unit module WWW::MistralAI::Models;

use HTTP::Tiny;
use JSON::Fast;
use WWW::MistralAI::Request;


#============================================================
# Known models
#============================================================
# See : https://docs.mistral.ai/platform/endpoints

my $knownModels = Set.new(<mistral-tiny mistral-small mistral-medium mistral-embed>);


our sub mistralai-known-models() is export {
    return $knownModels;
}

#============================================================
# Compatibility of models and end-points
#============================================================

# See : https://docs.mistral.ai/platform/endpoints

my %endPointToModels =
        'embeddings' => <mistral-embed>,
        'chat/completions' => <mistral-tiny mistral-small mistral-medium>;

#| End-point to models retrieval.
proto sub mistralai-end-point-to-models(|) is export {*}

multi sub mistralai-end-point-to-models() {
    return %endPointToModels;
}

multi sub mistralai-end-point-to-models(Str $endPoint) {
    return %endPointToModels{$endPoint};
}

#| Checks if a given string an identifier of a chat completion model.
proto sub mistralai-is-chat-completion-model($model) is export {*}

multi sub mistralai-is-chat-completion-model(Str $model) {
    return $model ∈ mistralai-end-point-to-models{'generateMessage'};
}

#------------------------------------------------------------
# Invert to get model-to-end-point correspondence.
# At this point (2023-04-14) only the model "whisper-1" has more than one end-point.
my %modelToEndPoints = %endPointToModels.map({ $_.value.Array X=> $_.key }).flat.classify({ $_.key }).map({ $_.key => $_.value>>.value.Array });

#| Model to end-points retrieval.
proto sub mistralai-model-to-end-points(|) is export {*}

multi sub mistralai-model-to-end-points() {
    return %modelToEndPoints;
}

multi sub mistralai-model-to-end-points(Str $model) {
    return %modelToEndPoints{$model};
}

#============================================================
# Models
#============================================================

#| MistralAI models.
our sub MistralAIModels(
        :$format is copy = Whatever,
        Str :$method = 'tiny',
        Str :$base-url = 'https://api.mistral.ai/v1',
        :api-key(:$auth-key) is copy = Whatever,
        UInt :$timeout = 10) is export {
    #------------------------------------------------------
    # Process $auth-key
    #------------------------------------------------------
    # This code is repeated in other files.
    if $auth-key.isa(Whatever) {
        if %*ENV<MISTRAL_API_KEY>:exists {
            $auth-key = %*ENV<MISTRAL_API_KEY>;
        } else {
            note 'Cannot find Mistral.AI authorization key. ' ~
                    'Please provide a valid key to the argument auth-key, or set the ENV variable MISTRAL_API_KEY.';
            $auth-key = ''
        }
    }
    die "The argument auth-key is expected to be a string or Whatever."
    unless $auth-key ~~ Str;

    #------------------------------------------------------
    # Retrieve
    #------------------------------------------------------
    my Str $url = $base-url ~ '/v1/models';

    return mistralai-request(:$url, body => '', :$auth-key, :$timeout, :$format, :$method);
}
