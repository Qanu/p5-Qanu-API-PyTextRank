#!/usr/bin/env perl

use Test::Most tests => 1;

use Modern::Perl;
use Renard::Incunabula::API::PyTextRank;

subtest "Extract phrases from example text" => sub {
	my $text = <<EOF;
Compatibility of systems of linear constraints over the set of natural numbers.
Criteria of compatibility of a system of linear Diophantine equations, strict
inequations, and nonstrict inequations are considered. Upper bounds for
components of a minimal set of solutions and algorithms of construction of
minimal generating sets of solutions for all types of systems are given.
These criteria and the corresponding algorithms for constructing a minimal
supporting set of solutions can be used in solving all the considered types
systems and systems of mixed types.
EOF

	my @expected_phrases = (
		'linear diophantine equations',
		'linear constraints',
		'natural numbers',
	);

	my $tr = Renard::Incunabula::API::PyTextRank->new;
	my $data = $tr->get_text_rank( "$text" );

	cmp_deeply $data, superbagof(
		map {
			superhashof( { text => $_ } ),
		} @expected_phrases
	);
};

done_testing;
