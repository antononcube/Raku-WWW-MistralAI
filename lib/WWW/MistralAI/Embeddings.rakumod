
unit module WWW::MistralAI::Embeddings;

use WWW::MistralAI::Models;
use WWW::MistralAI::Request;
use JSON::Fast;

#============================================================
# Embeddings
#============================================================

#| MistralAI embeddings.
our proto MistralAIEmbeddings($prompt,
                              :$model = Whatever,
                              :$encoding-format = Whatever,
                              :api-key(:$auth-key) is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'https://api.mistral.ai/v1'
                              ) is export {*}


#| MistralAI embeddings.
multi sub MistralAIEmbeddings($prompt,
                              :$model is copy = Whatever,
                              :$encoding-format is copy = Whatever,
                              :api-key(:$auth-key) is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'tiny',
                              Str :$base-url = 'https://api.mistral.ai/v1') {

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'mistral-embed'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ mistralai-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ mistralai-known-models;

    #------------------------------------------------------
    # Process $encoding-format
    #------------------------------------------------------
    if $encoding-format.isa(Whatever) { $encoding-format = 'float'; }
    die "The argument \$encoding-format is expected to be Whatever or one of the strings 'float' or 'base64'."
    unless $encoding-format ~~ Str && $encoding-format.lc ∈ <float base64>;

    #------------------------------------------------------
    # MistralAI URL
    #------------------------------------------------------

    my $url = $base-url ~ '/v1/embeddings';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    if ($prompt ~~ Positional || $prompt ~~ Seq) && $method ∈ <tiny> {

        return mistralai-request(:$url,
                body => to-json({ input => $prompt.Array, :$model, encoding_format => $encoding-format }),
                :$auth-key, :$timeout, :$format, :$method);

    } else {

        return mistralai-request(:$url,
                body => to-json({ input => $prompt.Array, :$model, encoding_format => $encoding-format }),
                :$auth-key, :$timeout, :$format, :$method);
    }
}
