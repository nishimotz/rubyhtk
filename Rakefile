#!/usr/bin/ruby -Ku
# Rakefile
# 

require 'fileutils'
require 'protohmm'

WORDS = %w(one two three four five six seven eight nine oh zero sil)

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
  WORDS.each do |model|
    num_states = 20
    vec_size = 39
    protohmm model, "_proto", num_states, vec_size 
  end
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

desc "___ hinit"
task :hinit do
  FileUtils.mkdir_p "_hmm0"
  sh "HInit  -L _label -S _trainlist_even -H _proto/one -M _hmm0 -l one one"
end

desc "hcompv"
task :hcompv do
  FileUtils.mkdir_p "_hmm0"
  WORDS.each do |w|
    sh "HCompV -m -S _trainlist_even -M _hmm0 _proto/#{w}"
  end
end

desc "___ hrest"
task :hrest do
  FileUtils.mkdir_p "_hmm0"
  sh "HRest  -L _label -S _trainlist_even -H _proto/one -M _hmm0 -l one one"
end

desc "herest"
task :herest do
  FileUtils.mkdir_p "_hmm1"
  sh "HERest -L _label -S _trainlist_even -d _hmm0 -M _hmm1 -C config.herest models"
end
