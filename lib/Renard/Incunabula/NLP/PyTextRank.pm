use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::NLP::PyTextRank;
# ABSTRACT: Provides access to PyTextRank

use Renard::Incunabula::Common::Types qw(Str);
use Moo;

use JSON::MaybeXS qw(decode_json);
use Path::Tiny;

use Inline::Python qw();
use Inline Python => <<'END';
import pytextrank

def _get_text_rank(doc_text, path_stage1, path_stage2):
  doc_text = doc_text.decode('UTF-8')
  path_stage1 = path_stage1.decode('UTF-8')
  path_stage2 = path_stage2.decode('UTF-8')
  doc_data = [ { "id": "777", "text": doc_text} ]
  with open(path_stage1, 'w') as f:
    for graf in pytextrank.parse_doc(doc_data):
        f.write("%s\n" % pytextrank.pretty_print(graf._asdict()))
  graph, ranks = pytextrank.text_rank(path_stage1)
  with open(path_stage2, 'w') as f:
    for rl in pytextrank.normalize_key_phrases(path_stage1, ranks):
      f.write("%s\n" % pytextrank.pretty_print(rl._asdict()))
END

=method get_text_rank

Returns the PyTextRank data for a given document.

=cut
method get_text_rank( (Str) $document ) {
	my $intermediate = Path::Tiny->tempfile;
	my $output = Path::Tiny->tempfile;

	use Try::Tiny;
	try {
		_get_text_rank( "$document", "$intermediate" , "$output");
	} catch {
		warn "$_";
	};

	my @data = map { decode_json($_) } $output->lines_utf8;

	\@data;
}


1;
=head1 SEE ALSO

L<Repository information|http://project-renard.github.io/doc/development/repo/p5-Renard-Incunabula-NLP-PyTextRank/>

=cut
