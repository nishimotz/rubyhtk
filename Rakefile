#!/usr/bin/ruby -Ku
# Rakefile
# 

require 'fileutils'
require 'protohmm'

task :default => [:mfc] do end

desc "create mfc data"
task :mfc => ["config.hcopy", "script.hcopy"] do
  sh "HCopy -C config.hcopy -S script.hcopy"
end

desc "create protohmm"
task :protohmm do 
  FileUtils.mkdir_p "_proto"
  %w(one two three sil).each do |model|
    protohmm model, "_proto"
  end
end

desc "hinit"
task :hinit do
  
end
