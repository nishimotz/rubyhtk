#!/usr/bin/ruby -Ku
# rakefile.rb
# rubyhtk by Takuya Nishimoto (nishimotz)

require 'fileutils'
require 'lib/protohmm'
require 'lib/fname2lab'
require 'lib/model'
require 'lib/evaluation'
require 'config/task'
require 'env'
require 'logger'

log = Logger.new("_logfile.log")

desc "preparations"
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

desc "train models and evaluate"
task :eval => [:dir, :mfcc, :mfcclist, :label, :wdnet] do 
  data = ["_script/mfcclist0", "_script/mfcclist1"]
  label  = "_label_ph"
  1.upto(2) do |i|
    puts "pass #{i}"
    recout = "_recout_cv#{i}.mlf"
    evalout = "_eval_cv#{i}"
    Evaluation.basedir = "_hmm_cv#{i}"
    Evaluation.mixup_train(data[0], label)
    Evaluation.hvite(data[1], recout)
    Evaluation.hresults(recout, evalout)
    data = data.unshift.push(data.shift) # [1,2,3,4] => [2,3,4,1]
  end
end

