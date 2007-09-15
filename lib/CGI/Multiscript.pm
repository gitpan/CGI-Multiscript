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

our $VERSION = '0.70';


# Preloaded methods go here.
our $writeflag = 0;
our $tmpfilename;
our $TMPFILE;

sub execute {
my ($filename, $version, $lang, $pargs) = @_;

my $line;

open (CODEFILE, $filename) or die "Can't open $filename";
    $tmpfilename = get_tmpfilename();

    # print "Creating a new script temp file $tmpfilename\n";
    # print "Creating a new script temp file $tmpfilename\n";
    umask 077;
    open ($TMPFILE, ">$tmpfilename") or die $!;

    while ($line = <CODEFILE>) {
       # print $line;
       if ($line =~ /^(<code ruby>\n)/) {
           set_writeflag(1);
       }
       elsif ($line =~ /(^<\/code ruby>\n)/) {
          clear_writeflag(1);
       }
       elsif ($line =~ /(^<code perl>\n)/) {
           set_writeflag(2);
       }
       elsif ($line =~ /(^<\/code perl>\n)/) {
           clear_writeflag(2);
       }
       elsif ($line =~ /(^<code python>\n)/) {
           set_writeflag(3);
       }
       elsif ($line =~ /(^<\/code python>\n)/) {
           clear_writeflag(3);
       }
       elsif ($line =~ /(^<code>\n)/) {
           set_writeflag(4);
       }
       elsif ($line =~ /(^<\/code>\n)/) {
           clear_writeflag(4);
       }
       else
       {
          if ($writeflag != 0) {
	      print $TMPFILE $line; 
	  }
       }
      }
# print "running the script\n";
# system("perl $tmpfilename");
close($TMPFILE);
close(CODEFILE);
unlink($tmpfilename);

}

sub get_tmpfilename() {
    my $tmpname;
    my $random;

    $tmpname = ".ms.";
    srand(time());
    $random = rand();
    $tmpname .= "$$";
    $tmpname .= $random;
    $tmpname .= ".tmp";

    print "tmpname = $tmpname\n";

    return ($tmpname);

}

sub set_writeflag()
{
  # local $writeflag;
  my $flag = $_[0];
  if ($writeflag != 0) {
      print "Code Error -- Not allowed nested code within code!!\n";
      exit(1);
  }
  $writeflag = $flag; 

}

sub clear_writeflag()
{
  my $flag = $_[0];
  my $returncode = 0;
  if ($writeflag != $flag) {
     print "Code Error -- Not allowed a different end tag to close a tag!!\n";
  }
  if ($writeflag == 1) { $returncode = system("ruby $tmpfilename"); }
  if ($writeflag == 2) { $returncode = system("perl $tmpfilename"); } 
  if ($writeflag == 3) { $returncode = system("python $tmpfilename"); } 
  if ($writeflag == 4) { $returncode = system("tcsh $tmpfilename"); } 
  seek($TMPFILE, 0, 0);
  truncate($TMPFILE, 0);
  $writeflag = 0;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
#

=head1 NAME

CGI::Multiscript - Perl extension for Multiscript programming

=head1 SYNOPSIS

  use CGI::Multiscript;
  Multiscript::execute("test_hello.ms", "version", "perl", "args");

=head1 DESCRIPTION

- a Perl Module that allows for multi script programming from Perl scripts.
The program will allow Perl, Python, Ruby or Shell or any other language to coexist in the same script. 
The scripts can be given version attributes and are dillineated by tags. 
 
This program will run a multiscript program according to command options. 


=head2 EXPORT

The project page is mirrored on sourceforge.net and at http://www.mad-dragon.com/multiscript.html.

=head1 SEE ALSO

http://mad-dragon.com/multiscript

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Nathan Ross, <lt>morgothii@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Nathan Ross

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
