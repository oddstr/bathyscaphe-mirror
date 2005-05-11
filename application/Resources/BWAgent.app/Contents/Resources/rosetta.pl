#!/usr/bin/perl

#rosseta.pl - ユーザ定義リストの更新
#tsawada2 memo:
#ARGV[0] is downloaded html file fullpath
#ARGV[1] is board.plist's fullpath
 
for(split ">", curl("$ARGV[0]")){
if(m#HREF=http://(.+?)\.2ch\.net/(.+?)/#){$table{$2}=$1; }
}
treat("$ARGV[1]");
sub treat{
my $plist=shift;$plist=~s/~/$ENV{HOME}/;
open(IN,"$plist");undef $/;my $content=<IN>;close(IN);
$content=~s#http://(.*?)\.2ch\.net/(.+?)/#bosh($1,$2)#eg;
open(OUT,">$plist");print OUT $content;close(OUT);
}

sub bosh{
my ($oserv,$name)=@_;
my $serv=$table{$name};
if($serv eq "") {$serv=$oserv;}
unless($oserv eq $serv){print "$name moved: $oserv --> $serv\n";}
return "http://$serv.2ch.net/$name/";
}

sub curl {
my $a=shift; 
open(IN,"$a");undef $/;my $content=<IN>;close(IN);
return $content;
}