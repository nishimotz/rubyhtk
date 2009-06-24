#!/usr/bin/ruby -Ku
# Rakefile
# 

require 'fileutils'
require 'lib/protohmm'
require 'lib/fname2lab'
require 'lib/model'
require 'config/task'

task :default => [:dir, :mfcc, :mfcclist, :label] do end

task :clean do
  sh "rm -rf _*"
end

desc "prepare directories"
task :dir do 
  FileUtils.mkdir_p "_script"
  FileUtils.mkdir_p "_mfcc"
  FileUtils.mkdir_p "_label_wd"
  FileUtils.mkdir_p "_label_ph"
  FileUtils.mkdir_p "_proto"
  FileUtils.mkdir_p "_hmm0"
  FileUtils.mkdir_p "_hmm1"
end

desc "create hcopy.script"
task :hcopy_script => [:dir] do
  s = "_script/hcopy.script"
  File.open(s, "w") do |outfile|
    Dir.glob("#{DATADIR}/*.wav").sort.each do |f|
      outfile.puts f + " ./_mfcc/" + f.split(/\//)[-1].gsub(/\.wav/, '.mfc')
    end
  end
end

desc "create mfcc data"
task :mfcc => [:hcopy_script] do
  sh "HCopy -C config/config.hcopy -S _script/hcopy.script"
end

desc "mfcclist"
task :mfcclist do
  File.open("_script/mfcclist0", "w") do |outfile0|
    File.open("_script/mfcclist1", "w") do |outfile1|
      Dir.glob("_mfcc/*.mfc").sort.each_with_index do |f,i|
        if i % 2 == 0
          outfile0.puts f
        else 
          outfile1.puts f
        end
      end
    end
  end
end

desc "label"
task :label do
  fname2lab_ph
  fname2lab_wd
end

desc "wdnet"
task :wdnet do
  sh "HParse config/gram _script/wdnet"
end

task :train do 
  data   = "_script/mfcclist0"
  label  = "_label_ph"

  proto = Model.new.proto
  m0 = Model.new.compv(proto, data)
  m1 = Model.new.erest(m0, data, label)
  m2 = Model.new.mixup1(m1)
  m3 = Model.new.mixup2(m2, data, label)
  puts m3
end

desc "hvite"
task :hvite do
  dir = "_hmm4"
  sh "HVite -H #{dir}/newMacros -S _script/mfcclist1 -L _label -w _script/wdnet -i _recout.mlf config/dict config/models"
end

desc "hresults"
task :hresults do
  sh "HResults -L _label_wd config/models _recout.mlf"
end

