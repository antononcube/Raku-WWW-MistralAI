# WWW::MistralAI

## In brief

This Raku package provides access to the machine learning service [MistralAI](https://mistral.ai), [MAI1].
For more details of the MistralAI's API usage see [the documentation](https://docs.mistral.ai), [MAI2].

**Remark:** To use the MistralAI API one has to register and obtain authorization key.

**Remark:** This Raku package is much "less ambitious" than the official Python package, [MAIp1], developed by MistralAI's team.
Gradually, over time, I expect to add features to the Raku package that correspond to features of [MAIp1].

This package is very similar to the packages 
["WWW::OpenAI"](https://github.com/antononcube/Raku-WWW-OpenAI), [AAp1], and 
["WWW::PaLM"](https://github.com/antononcube/Raku-WWW-PaLM), [AAp2]. 

"WWW::MistralAI" can be used with (is integrated with) 
["LLM::Functions"](https://github.com/antononcube/Raku-LLM-Functions), [AAp3], and
["Jupyter::Chatbook"](https://github.com/antononcube/Raku-Jupyter-Chatbook), [AAp5].

Also, of course, prompts from 
["LLM::Prompts"](https://github.com/antononcube/Raku-LLM-Prompts), [AAp4],
can be used with MistralAI's functions.

-----

## Installation

Package installations from both sources use [zef installer](https://github.com/ugexe/zef)
(which should be bundled with the "standard" Rakudo installation file.)

To install the package from [Zef ecosystem](https://raku.land/) use the shell command:

```
zef install WWW::MistralAI
```

To install the package from the GitHub repository use the shell command:

```
zef install https://github.com/antononcube/Raku-WWW-MistralAI.git
```

----

## Usage examples

**Remark:** When the authorization key, `auth-key`, is specified to be `Whatever`
then the functions `mistralai-*` attempt to use the env variable `MISTRAL_API_KEY`.

### Universal "front-end"

The package has an universal "front-end" function `mistral-playground` for the 
[different functionalities provided by MistralAI](https://docs.mistral.ai).

Here is a simple call for a "chat completion":

```perl6
use WWW::MistralAI;
mistralai-playground('Where is Roger Rabbit?');
```

Another one using Bulgarian:

```perl6
mistralai-playground('Колко групи могат да се намерят в този облак от точки.', max-tokens => 300, random-seed => 234232, format => 'values');
```

**Remark:** The functions `mistralai-chat-completion` or `mistralai-completion` can be used instead in the examples above.
(The latter is synonym of the former.)


### Models

The current MistralAI models can be found with the function `mistralai-models`:

```perl6
*<id>.say for |mistralai-models;
```

### Code generation

There are two types of completions : text and chat. Let us illustrate the differences
of their usage by Raku code generation. Here is a text completion:

```perl6
mistralai-completion(
        'generate Raku code for making a loop over a list',
        max-tokens => 120,
        format => 'values');
```

Here is a chat completion:

```perl6
mistralai-completion(
        'generate Raku code for making a loop over a list',
        max-tokens => 120,
        format => 'values');
```


### Embeddings

Embeddings can be obtained with the function `mistralai-embeddings`. Here is an example of finding the embedding vectors
for each of the elements of an array of strings:

```perl6
my @queries = [
    'make a classifier with the method RandomForeset over the data dfTitanic',
    'show precision and accuracy',
    'plot True Positive Rate vs Positive Predictive Value',
    'what is a good meat and potatoes recipe'
];

my $embs = mistralai-embeddings(@queries, format => 'values', method => 'tiny');
$embs.elems;
```

Here we show:
- That the result is an array of four vectors each with length 1536
- The distributions of the values of each vector

```perl6
use Data::Reshapers;
use Data::Summarizers;

say "\$embs.elems : { $embs.elems }";
say "\$embs>>.elems : { $embs>>.elems }";
records-summary($embs.kv.Hash.&transpose);
```

Here we find the corresponding dot products and (cross-)tabulate them:

```perl6
use Data::Reshapers;
use Data::Summarizers;
my @ct = (^$embs.elems X ^$embs.elems).map({ %( i => $_[0], j => $_[1], dot => sum($embs[$_[0]] >>*<< $embs[$_[1]])) }).Array;

say to-pretty-table(cross-tabulate(@ct, 'i', 'j', 'dot'), field-names => (^$embs.elems)>>.Str);
````

**Remark:** Note that the fourth element (the cooking recipe request) is an outlier.
(Judging by the table with dot products.)

### Chat completions with engineered prompts

Here is a prompt for "emojification" (see the
[Wolfram Prompt Repository](https://resources.wolframcloud.com/PromptRepository/)
entry
["Emojify"](https://resources.wolframcloud.com/PromptRepository/resources/Emojify/)):

```perl6
my $preEmojify = q:to/END/;
Rewrite the following text and convert some of it into emojis.
The emojis are all related to whatever is in the text.
Keep a lot of the text, but convert key words into emojis.
Do not modify the text except to add emoji.
Respond only with the modified text, do not include any summary or explanation.
Do not respond with only emoji, most of the text should remain as normal words.
END
```

Here is an example of chat completion with emojification:

```perl6
mistralai-chat-completion([ system => $preEmojify, user => 'Python sucks, Raku rocks, and Perl is annoying'], max-tokens => 200, format => 'values')
```

-------

## Command Line Interface

### Playground access

The package provides a Command Line Interface (CLI) script:

```shell
mistralai-playground --help
```

**Remark:** When the authorization key argument "auth-key" is specified set to "Whatever"
then `mistralai-playground` attempts to use the env variable `MISTRAL_API_KEY`.


--------

## Mermaid diagram

The following flowchart corresponds to the steps in the package function `mistralai-playground`:

```mermaid
graph TD
	UI[/Some natural language text/]
	TO[/"MistralAI<br/>Processed output"/]
	WR[[Web request]]
	MistralAI{{https://console.mistral.ai}}
	PJ[Parse JSON]
	Q{Return<br>hash?}
	MSTC[Compose query]
	MURL[[Make URL]]
	TTC[Process]
	QAK{Auth key<br>supplied?}
	EAK[["Try to find<br>MISTRAL_API_KEY<br>in %*ENV"]]
	QEAF{Auth key<br>found?}
	NAK[/Cannot find auth key/]
	UI --> QAK
	QAK --> |yes|MSTC
	QAK --> |no|EAK
	EAK --> QEAF
	MSTC --> TTC
	QEAF --> |no|NAK
	QEAF --> |yes|TTC
	TTC -.-> MURL -.-> WR -.-> TTC
	WR -.-> |URL|MistralAI 
	MistralAI -.-> |JSON|WR
	TTC --> Q 
	Q --> |yes|PJ
	Q --> |no|TO
	PJ --> TO
```

--------

## References

### Packages

[AAp1] Anton Antonov,
[WWW::OpenAI Raku package](https://github.com/antononcube/Raku-WWW-OpenAI),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[WWW::PaLM Raku package](https://github.com/antononcube/Raku-WWW-PaLM),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[LLM::Functions Raku package](https://github.com/antononcube/Raku-LLM-Functions),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[LLM::Prompts Raku package](https://github.com/antononcube/Raku-LLM-Prompts),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Jupyter::Chatbook Raku package](https://github.com/antononcube/Raku-Jupyter-Chatbook),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[MAI1] MistralAI, [MistralAI platform](https://mistral.ai).

[MAI2] MistralAI Platform documentation, [MistralAI documentation](https://docs.mistral.ai).

[MAIp1] MistralAI,
[https://github.com/mistralai/client-python),
(2023),
[GitHub/mistralai](https://github.com/mistralai).

