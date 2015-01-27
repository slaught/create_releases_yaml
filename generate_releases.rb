#!/usr/bin/env ruby

require 'bundler/setup'
require 'Getopt/Declare'

require 'date'
require 'yaml'
require 'json'
require 'open-uri'

$DEBUG = false
ARG_DEF= <<EOF
         <owner>            Organizaiton or User who is the owner
         <repo>             Repository of releasesoad
         -debug             Enable debug output
                                    {$DEBUG = true }
EOF

def api_url(owner,repo)
  "https://api.github.com/repos/#{owner}/#{repo}/releases"
end

def map_release(json_object)
  json_object.map {|release|
      next if release["draft"]    
      ver = release["tag_name"].delete('v')
      d = DateTime.parse(release["published_at"])
      d = d.to_time.to_date.strftime("%Y-%m-%d")
      %Q(- version: #{ver}\n  date: #{d}\n)
  }.compact
end

def main(args)
    owner = args['owner']
    repo  = args['repo']
    owner = 'rubinius' if owner.nil?
    repo  = 'rubinius' if repo.nil?

    _raw = nil
    uri = URI.parse(api_url(owner,repo))
    uri.open do |fn|
         _raw = fn.readlines
    end
    if $DEBUG 
     File.open("releases.out.json",'w') do |io|
        io.print _raw.join("\n")
      end
    end
    releases_json_array = JSON.parse(_raw.join(""))
    final_release = map_release(releases_json_array)
    File.open("releases.yaml",'w') do |io|
        io.puts final_release.join("\n")
    end
      
end
main(Getopt::Declare.new(ARG_DEF))
