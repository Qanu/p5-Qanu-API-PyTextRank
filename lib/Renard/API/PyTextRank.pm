use Renard::Incunabula::Common::Setup;
package Renard::API::PyTextRank;
# ABSTRACT: Provides access to PyTextRank

use Renard::Incunabula::Common::Types qw(Str);
use Moo;

use JSON::MaybeXS qw(decode_json);
use Path::Tiny;

use Inline::Python qw();
use Inline Python => <<'END';
import spacy
import pytextrank

def _get_text_rank(doc_text):
  doc_text = doc_text.decode('UTF-8')

  # load a spaCy model, depending on language, scale, etc.
  nlp = spacy.load("en_core_web_sm")

  # add PyTextRank to the spaCy pipeline
  tr = pytextrank.TextRank()
  nlp.add_pipe(tr.PipelineComponent, name="textrank", last=True)

  doc = nlp(doc_text)

  return doc._.phrases
END

=method get_text_rank

Returns the PyTextRank data for a given document.

=cut
method get_text_rank( (Str) $document ) {
	use Try::Tiny;
	my $data = try {
		_get_text_rank( "$document");
	} catch {
		warn "$_";
	};

	my @phrase_data = map {
		my $phrase = $_;
		+{ %$phrase{qw(text rank count)} }
	} @$data;

	\@phrase_data;
}


1;
=head1 SEE ALSO

L<Repository information|http://project-renard.github.io/doc/development/repo/p5-Renard-API-PyTextRank/>

=cut
