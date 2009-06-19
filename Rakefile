#!/usr/bin/ruby -Ku
# Rakefile
# 

require 'fileutils'
require 'protohmm'

task :default => [:hcopy_script] do end

desc "create hcopy.script"
task :hcopy_script do
  FileUtils.mkdir_p "_script"
  FileUtils.mkdir_p "_mfcc"
  s = "_script/hcopy.script"
  datadir = "../2009jun18/0.7"
  File.open(s, "w") do |outfile|
    Dir.glob("#{datadir}/*.wav").sort.each do |f|
      outfile.puts f + " ./_mfcc/" + f.split(/\//)[-1].gsub(/\.wav/, '.mfc')
    end
  end
end

desc "create mfcc data"
task :mfcc do
  sh "HCopy -C config.hcopy -S _script/hcopy.script"
end

desc "create proto"
task :proto do 
  FileUtils.mkdir_p "_proto"
  %w(one two three four five six seven eight nine oh zero sil).each do |model|
    num_states = 20
    vec_size = 39
    protohmm model, "_proto", num_states, vec_size 
  end
end

desc "hinit"
task :hinit do
#  w = "hai"
#  sh "HInit -S _trainlist -M hmm0 -H _proto/#{w}.hmm -l #{w} -L label #{w}"
end

desc "trainlist"
task :trainlist do
  File.open("_trainlist_even", "w") do |outfile|
    Dir.glob("_mfcc/*.mfc").sort.each_with_index do |f,i|
      if i % 2 == 0
        outfile.puts f
      end
    end
  end
end

desc "label"
task :label do
  FileUtils.mkdir_p "_label"
  Dir.glob("_mfcc/*.mfc").sort.each_with_index do |f,i|
    name = f.split(/\//)[-1].gsub(/\.mfc/, '')
    File.open("_label/#{name}.lab", "w") do |outfile|
      outfile.puts "sil"
      name.split(/_/)[-1].split(//)[0..-2].each do |d|
        if d == 'Z'
          outfile.puts "zero"
        else
          outfile.puts %w(oh one two three four five six seven eight nine)[d.to_i]
        end
      end
      outfile.puts "sil"
    end
  end
end

desc "herest"
task :herest do
  FileUtils.mkdir_p "_hmm0"
  sh "HERest -C config.herest -L _label -S _trainlist_even -d _proto -M _hmm0 models"
end
