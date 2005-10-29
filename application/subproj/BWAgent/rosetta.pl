#!/usr/bin/perl

#rosseta.pl - ユーザ定義リストの更新
#tsawada2 memo:
#ARGV[0] is downloaded html file fullpath
#ARGV[1] is board.plist's fullpath
 
my @src=split(">", curl("$ARGV[0]"));@src=reverse @src;
for(@src){
if(m#HREF=http://(\w+?\.(?:2ch\.net|bbspink\.com))/(\w+?)/#){$table{$2}=$1;}
}

treat("$ARGV[1]");
sub treat{
my $plist=shift;$plist=~s/~/$ENV{HOME}/;
open(IN,"$plist");undef $/;my $content=<IN>;close(IN);
$content=~s#http://(\w+?\.(?:2ch\.net|bbspink\.com))/(\w+?)/#bosh($1,$2)#eg;
open(OUT,">$plist");print OUT $content;close(OUT);
}

sub bosh{
my ($oserv,$name)=@_;
my $serv=$table{$name};
if($serv eq "") {$serv=$oserv;}
unless($oserv eq $serv){print "$name moved: $oserv --> $serv\n";}
return "http://$serv/$name/";
}

sub curl {
my $a=shift; 
open(IN,"$a");undef $/;my $content=<IN>;close(IN);
return $content;
}