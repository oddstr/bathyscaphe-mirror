#!/usr/local/bin/ruby

require 'cgi'

puts CGI::escape((File::new(ARGV[0]).readline).chomp)
