package PESGenerator;

use Data::Dumper;

sub new
{
    my $class = shift;
    my %param = (
	-offset => [0, 0],
	-descent => 800,
	-ascent => 200,
	@_,
    );
    my $this = bless {
	basename => $param{'-basename'},
	fontname => $param{'-fontname'},
	weight => $param{'-weight'},
	copyright => $param{'-copyright'},
	input_sfd => $param{'-input_sfd'},
	output_sfd => $param{'-output_sfd'},
	scratch_build => ($param{'-input_sfd'} ne $param{'-output_sfd'}),
	offset => $param{'-offset'},
	descent => $param{'-descent'},
	ascent => $param{'-ascent'},
	eps_files => [],
    }, $class;
    return $this;
}

sub add
{
    my $this = shift;
    my $path = shift;
    if (-e $path) {
	push @{$this->{eps_files}}, $path;
	return 1;
    } else {
	return 0;
    }
}

sub save
{
    my $this = shift;
    my $path = shift;
    open OUT, ">$path";
    binmode OUT;
    # Header
    print OUT "#!/usr/local/bin/pfaedit -script\n";
    if (0 >= @{$this->{eps_files}}) {
	return 0;
    }
    print OUT <<"__EOB__";
Open("$this->{input_sfd}")
# Set panose (workaround)
panose = Array(10)
panose[0] = 2; panose[1] = 0; panose[2] = 6; panose[3] = 9; panose[4] = 6
panose[5] = 0; panose[6] = 0; panose[7] = 0; panose[8] = 0; panose[9] = 0
i = 0; while (i < 10); SetPanose(i, panose[i]); ++i; endloop
__EOB__
    # Header for scratch
    if ($this->{scratch_build}) {
	print OUT <<"__EOB__";
# For scratch build
SetFontNames("$this->{basename}", "$this->{fontname}", "$this->{fontname}", "$this->{weight}", "$this->{copyright}")
__EOB__
    }
    # Glyphs
    print OUT "# Output glyphs\n";
    for my $eps_file (@{$this->{eps_files}}) {
	if ($eps_file !~ m/\/u([[:xdigit:]]+)\.eps$/) {
	    printf STDERR "Skip: can't get character code: $eps_file\n";
	    next;
	}
	my $code = $1;
	my $width = &_get_width($eps_file);
	if ($width < 0) {
	    printf STDERR "Skip: can't get width: $eps_file\n";
	    next;
	}
	printf OUT "Print(\"Add %s\")\n", $eps_file;
	printf OUT "Select(0x%s)\n", $code;
	printf OUT "Clear()\n";
	printf OUT "Import(\"%s\")\n", $eps_file;
	printf OUT "Move(%d, %d)\n", $this->{offset}->[0], $this->{offset}->[1];
	printf OUT "SetWidth(%d)\n", $width;
    }
    # Footer
    print OUT <<"__EOB__";
# Save SFD and quit
Save("$this->{output_sfd}")
Quit()
__EOB__
    close OUT;
    return 1;
}

sub _get_width
{
    my $filename = shift;
    my $width = -1;
    open IN, $filename;
    while (<IN>) {
	chomp;
	if (m/^%%BoundingBox:\s+\d+\s+\d+\s+(\d+)\s+(\d+)/) {
	    $width = $1 + 0;
	    last;
	}
    }
    close IN;
    return $width;
}

1;
