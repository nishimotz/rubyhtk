#!/usr/bin/ruby -Ku
# Rakefile
# 

require 'fileutils'
require 'lib/protohmm'
require 'lib/fname2lab'
require 'lib/model'
require 'config/task'

task :default => [:dir, :mfcc, :mfcclist, :label, :wdnet] do end

task :clean do
  sh "rm -rf _*"
end

task :dir do 
  %w[ _script _mfcc _label_wd _label_ph ].each do |d| 
    FileUtils.mkdir_p d 
  end
end

task :hcopy_script => [:dir] do
  s = "_script/hcopy.script"
  File.open(s, "w") do |outfile|
    Dir.glob("#{DATADIR}/*.wav").sort.each do |f|
      outfile.puts f + " ./_mfcc/" + f.split(/\//)[-1].gsub(/\.wav/, '.mfc')
    end
  end
end

task :mfcc => [:hcopy_script] do
  sh "HCopy -C config/config.hcopy -S _script/hcopy.script"
end

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

task :label do
  fname2lab_ph
  fname2lab_wd
end

task :wdnet do
  sh "HParse config/gram _script/wdnet"
end

task :train do 
  data0  = "_script/mfcclist0"
  label  = "_label_ph"
  models = []
  models << Model.first_train(data0,label)
  while models.last.num_mixes < TARGET_NUM_MIXES
    models << models.last.mixup_train(data0,label)
  end
  File.open("_hmm_last", "w") do |f|
    f.puts models.last.dir
  end
end

task :hvite do
  last = open("_hmm_last").read.chomp
  Model.new(last).vite("_script/mfcclist1", "_recout.mlf")
end

task :hresults do
  sh "HResults -f -L _label_wd config/models _recout.mlf > _eval"
  sh "cat _eval"
end
