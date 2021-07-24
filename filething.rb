#!/usr/bin/env ruby

#
# This program should be launched via `bundle exec`.
#
# When called, this program will spider a given directory
# (either ARGV[0] if passed in, otherwise ENV['PWD']) for
# all files with a given extension. Default extensions are
# for video files: { m4v: 0, mkv: 0, mp4: 0, avi: 0 }
#

require 'rubygems'
require 'bundler/setup'
require 'pry'

exts = { m4v: 0, mkv: 0, mp4: 0, avi: 0 }

# If ARGV[0] is a path, look there; otherwise look in
# the user's current directory
if ARGV.count > 0
  loc = ARGV[0]
  puts "Looking for files in ${loc}..."
else
  loc = ENV['PWD']
end

# If any extensions after the location, add those to
# the extensions
if ARGV.count > 1 && ARGV[1..-1].count > 0
  ARGV[1..-1].each do |x|
    unless exts.keys.include?(x)
      k = x.sub(/\./, '')
      exts[:"#{k}"] = 0
    end
  end
end

# Check to make sure the dir in question exits
unless Dir.exist?(loc)
  puts "Directory does not exist: #{loc}"
  exit 1
end

# Output information about what we're going to try here
puts <<~EOF
  Search path: #{loc}
  Extensions: #{exts.keys.join(', ')}
EOF

# Glob all the files recursively...
# files = Dir.glob["#{loc}/**/*.#{exts.keys.join(',')}"]
files = Dir.glob("#{loc}/**/*[.#{exts.keys.join(',.')}]")

binding.pry
