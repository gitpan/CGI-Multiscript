package CGI::Multiscript;

use 5.008004;
use strict;
use warnings;

use IO::Handle;
use IO::File;
use Fcntl;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use CGI::Multiscript ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.71';


# Preloaded methods go here.
our $writeflag = 0;
our $tmpfilename;
our $TMPFILE;
our $default;

sub new {
        my ($filename) = @_;
	my ($self) = { };
	bless ($self);
	$self->{'FILE'} = $filename;
	return $self;
}

# set default language
sub setDefault {
	my ($value) = @_;
	$default = $value;
}

sub getDefault {
	return $default;
}

sub setFilename {
        my ($self, $value) = @_;
        $self->{'FILE'} = $value;
}

sub getFilename {
        my ($self) = @_;
        return $self->{'FILE'};
}

sub displayFilename {
	my ($self) = @_;
	print $self->{'FILE'}, "\n";
}

sub addLanguage {
	my ($self, $lang, $args) = @_;
	$self->{$lang} = $args;
}

sub addVersion {
	my ($self, $version, $args) = @_;
	$self->{$version} = $args;
}

sub addName {
	my ($self, $version, $args) = @_;
	$self->{$version} = $args;

}

sub get {
        my ($self, $key) = @_;
        return $self->{$key};
}

sub execMultiscript {
	my ($self, $filename) = @_;

}

sub execute {
my ($self) = @_;

my $filename;
my $line;
my $currentLanguage;
my $currentVersion;
my $currentName;
my $currentArgs;

$filename = $self->{'FILE'};

open (CODEFILE, $filename) or die "Can't Open Multiscript $filename";
    $tmpfilename = get_tmpfilename();

    # print "Creating a new script temp file $tmpfilename\n";
    umask 077;
    # umask 022;
    open ($TMPFILE, ">$tmpfilename") or die $!;

    $currentLanguage = "";
    $currentVersion = "";
    $currentName = "";
    $currentArgs = "";

    while ($line = <CODEFILE>) {
       # print $line;
       if ($line =~ /^<code\s+lang=["](\S+)["]\s+ver=["](\S+)["]\s+name=["](\S+)["]\s+args=["](\S+)["]>\n/) {
		$currentLanguage = $1;
		$currentVersion  = $2;
		$currentName 	 = $3;
		$currentArgs 	 = $4;
		# print "Current ", $currentLanguage, " ", $currentVersion, "\n";
           	set_writeflag(1);
       }
       if ($line =~ /^<code\s+lang=["](\S+)["]>\n/) {
       		# print "Current Code lang $line\n";
       		$currentLanguage = $1;
		$currentArgs = "";
		set_writeflag(2);
       }
       elsif ($line =~ /^<code>\n/) {
       		# print "Current Code $line\n";
		
       		$currentLanguage = "";
		$currentArgs = "";
           	set_writeflag(3);
       }
       elsif ($line =~ /^<\/code>\n/) {
           	clear_writeflag(1);
		# if should run and is in argument list
		execTmpfile($currentLanguage, $currentArgs);
		truncateTmpfile();
		$currentLanguage = "";
		$currentVersion = "";
		$currentName = "";
		$currentArgs = "";
       }
       else
       {
          if ($writeflag != 0) {
	      # print "Writing", $line;
	      print $TMPFILE $line; 
	  }
       }
      }


close($TMPFILE);
close(CODEFILE);
unlink($tmpfilename);

}

# Create a temporary file
# With a random name
sub get_tmpfilename() {
	my $tmpname;
	my $random;

	$tmpname = ".ms.";
	srand(time());
	$random = rand();
	$tmpname .= "$$";
	$tmpname .= $random;
	$tmpname .= ".tmp";

	# print "tmpname = $tmpname\n";

	return ($tmpname);

}

sub set_writeflag()
{
	my $flag = $_[0];
	if ($writeflag != 0) {
	print "Code Error -- Not allowed nested code within code!!\n";
		unlink($tmpfilename);
		exit(1);
	}
	$writeflag = $flag; 

}

sub clear_writeflag()
{
  	my $flag = $_[0];
  	$writeflag = 0;
}

sub execTmpfile()
{
	my ($lang, $args) = @_;
	my $returncode;
	if (($lang eq "") && ($args eq "")) {
		$returncode = system("$default$tmpfilename");
	}
	elsif (($lang ne "") && ($args eq "")) {
		$returncode = system("$lang $tmpfilename");
	}
	elsif (($lang eq "") && ($args eq "")) {
		$returncode = system("$default$tmpfilename $args");
	}
}


sub truncateTmpfile()
{
	seek($TMPFILE, 0, 0);
	truncate($TMPFILE, 0);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
#

=head1 NAME

CGI::Multiscript - Perl extension for Multiscript programming

=head1 SYNOPSIS

use CGI::Multiscript;

CGI::Multiscript::setDefault("./");
CGI::Multiscript::setDefault("sh ");
print "Default execution ", CGI::Multiscript::getDefault(), "\n";

$ms = CGI::Multiscript::new("test_hello.ms");
$ms->setFilename("t/test_hello.ms");
$ms->addLanguage('Perl');
print "Current filename ", $ms->getFilename(), "\n";

$ms->execute();  

=head1 DESCRIPTION

CGI::Multiscript is a Perl Module that allows for Perl scripts to run and execute Multiscript files.
CGI::Multiscript will allow Perl, Python, Ruby or Shell or any other language to coexist in the same external script. 
The Multiscripts consist of multiple languages separated by code tags and attributes.
Multiscript files can be executed from a Perl scripti that uses CGI::Multiscript.
 
CGI::Multiscript will run an external multiscript program according to the execution options which
include language, version, name and command line arguments. 


=head2 EXPORT

The project page is mirrored on sourceforge.net and at http://www.mad-dragon.com/multiscript.html.

=head1 SEE ALSO

http://mad-dragon.com/multiscript


=head1 AUTHOR

Nathan Ross, <lt>morgothii@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

GPL and Artistic

Copyright (C) 2007 by Nathan Ross

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
