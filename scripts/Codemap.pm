package Codemap;

use strict;
use Carp;
use Data::Dumper;
use UCSTable;

my $FILENAME_CODEMAP = 'codemap';

sub new
{
    my $class = shift;
    my $dir = shift;
    if (not -d $dir) {
	croak "Can't find codemap dir $dir\n";
    }
    my $codemap = shift;
    $codemap ||= $FILENAME_CODEMAP;
    my $this = bless {
	dir => $dir,
	name2codes => {},
	mapfile_path => '',
	mapfile_line => 0,
    }, $class;
    my $path = join('/', $dir, $codemap);
    # Read codemap file
    open CODEMAP, $path or croak "Can't find codemap file $path\n";
    $this->{mapfile_path} = $path;
    while (<CODEMAP>) {
	++$this->{mapfile_line};
	chomp;
	if (m/^\s*#/) {
	    if (m/^\s*#\s*encoding\s+(\S+)/) {
		$this->{ucstable} = new UCSTable($1);
	    } else {
		next;
	    }
	} elsif (m/^\s*$/) {
	    next;
	} else {
	    my @array = split " ";
	    my $eps_filename = shift @array;
	    my $eps_path = join('/', $this->{dir}, $eps_filename);
	    if (-f $eps_path) {
		my $ucs_array = $this->_map2ucs(\@array);
		#print "$eps_path : ".join(' ', @$ucs_array)."\n";
		$this->{name2codes}->{$eps_path} = $ucs_array;
	    }
	}
    }
    close CODEMAP;
    # Check files are not included in codemap
    opendir LS, $dir;
    for my $file (readdir LS) {
	next if $file =~ m/^(?:\.|\.\.|codemap)$/;
	my $path = join('/', $dir, $file);
	if (not exists $this->{name2codes}->{$path}) {
	    printf STDERR "$path isn't included in codemap file\n";
	}
    }
    closedir LS;
    return $this;
}

sub _map2ucs
{
    my $this = shift;
    my $codes = shift;
    my @ucs_array;
    if (not exists $this->{ucstable}) {
	for my $code (@$codes) {
	    if ($code =~ m/^0x([[:xdigit:]]+)(u)?$/ and defined $2) {
		push @ucs_array, sprintf('u%04x', hex($1));
	    } else {
		$this->_maperror($code);
	    }
	}
    } else {
	for my $code (@$codes) {
	    if ($code =~ m/^0x([[:xdigit:]]+)(u)?$/) {
		if (defined $2) {
		    push @ucs_array, sprintf('u%04x', hex($1));
		} else {
		    my $ucs = $this->{ucstable}->get($1);
		    if (defined $ucs) {
			push @ucs_array, sprintf('u%04x', $ucs);
		    } else {
			$this->_maperror($code);
		    }
		}
	    } else {
		$this->_maperror($code);
	    }
	}
    }
    return \@ucs_array;
}

sub _maperror
{
    my $this = shift;
    my $code = shift;
    printf STDERR ("Found code %s can't be map at line %d in %s\n",
	$code, $this->{mapfile_line}, $this->{mapfile_path});
}

sub keys
{
    my $this = shift;
    my @keys = keys(%{$this->{name2codes}});
    return \@keys;
}

sub get_codes
{
    my $this = shift;
    my $key = shift;
    if (exists $this->{name2codes}->{$key}) {
	return $this->{name2codes}->{$key};
    } else {
	return [];
    }
}

1;
