#!/usr/bin/perl

#sora.pl - 標準リストの新規生成
#tsawada2 memo:
#ARGV[0] is downloaded html file fullpath
#ARGV[1] is SJIS2UTF8's fullpath
#stdout に吐き出されるよ

@cat=split "<BR><B>", curl("$ARGV[0]");
shift @cat;for(@cat){
@lines=split "\n";
$s=shift @lines; $s=~m#^(.*?)</B>#i; $data[$cat]->{name}=$1;
$num=0;for $l(@lines){
if($l=~m#HREF=(http://[^ ]+).*>(.+?)</a>#i){
$data[$cat]->{list}[$num]{url}=$1;
$name_t=$2;
$name_t=~ s/&/&amp;/;
$data[$cat]->{list}[$num]{name}=$name_t;
$num++;
}
} $cat++;
}

$out.=<<EOS;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
EOS

for(@data){
$out.=<<EOS;
<dict>
<key>Contents</key>
<array>
EOS
for $s(@{$_->{list}}){
$out.=<<EOS;
<dict><key>Name</key>
<string>$s->{name}</string>
<key>URL</key>
<string>$s->{url}</string></dict>
EOS
}
$out.=<<EOS;
</array>
<key>Name</key>
<string>$_->{name}</string>
</dict>
EOS
}
$out.="</array></plist>";
open(OUT,"|'$ARGV[1]' ");
print OUT $out;
close(OUT);

sub curl {
my $a=shift; 
open(IN,"$a");undef $/;my $content=<IN>;close(IN);
return $content;
}