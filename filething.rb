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
require 'async'

@exts = { m4v: 0, mkv: 0, mp4: 0, avi: 0 }
@index = { m4v: [], mkv: [], mp4: [], avi: [] }
@paths = {}

# If ARGV[0] is a path, look there; otherwise look in
# the user's current directory
if ARGV.count > 0 && ARGV[0].length > 1 && Dir.exist?(ARGV[0])
  @loc = ARGV[0]
else
  @loc = ENV['PWD']
end

# If any extensions after the location, add those to
# the extensions
if ARGV.count > 1 && ARGV[1..-1].count > 0
  ARGV[1..-1].each do |x|
    unless @exts.keys.include?(x)
      k = x.sub(/\./, '')
      @exts[:"#{k}"] = 0
      @index[:"#{k}"] = []
    end
  end
end

def findEm(ext)
  files = Dir.glob("#{@loc}/**/*.#{ext.to_s.sub(/\./, '')}")
  @exts[ext] = files.count
  @index[ext] << files
  @index[ext].flatten!.uniq!
  # File.dirname(@index[:mp4][0]).sub(/#{ENV["PWD"]}/, '')
  # Update the @paths variable so we can get a full, clear accounting of what's where
#   files.each do |f|
#     @paths[File.dirname(f).sub(/#{@loc}/, '').to_sym]
#   end
end

# Glob all the files recursively...
@exts.keys.each do |e|
  Async do
    findEm(e)
  end
  Async do
    @exts.keys.each do |ext|
      @index[ext].each do |f|
        d = File.dirname(f.sub(/#{@loc}/, '')).sub(/\//, '')
        if @paths[d.to_sym].nil?
          @paths[d.to_sym] = { files: [] }
        end
        @paths[d.to_sym][:files] << f
      end
    end
  end
end


puts <<~EOF
  REPORT:
  =======
  Directory Searched:   #{@loc}
  For files ending in:  #{@exts.keys.join(',')}



EOF

@exts.keys.each do |e|
  puts <<~EOF
    #{e}:          #{@exts[e]}
  EOF
end

puts <<~EOF


EOF

@paths.keys.each do |k|
  puts <<~EOF
    #{k}                                           #{@paths[k][:files].count}
  EOF
end

puts <<~EOF



  Be advised: Other files beyond the above likely do exist in the searched
  directory.

  END OF REPORT
EOF
