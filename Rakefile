#!/usr/bin/ruby -Ku
# Rakefile
# 

require 'fileutils'
require 'lib/protohmm'
require 'lib/fname2lab'

# DATADIR = "../2009jun18/0.7"
DATADIR = "../../censrec4/clean1"

WORDS = %w(one two three four five six seven eight nine oh zero sil)

# task :default => [:hcopy_script] do end

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

#desc "___ hinit"
#task :hinit do
#  sh "HInit  -L _label -S _mfcclist_even -H _proto/one -M _hmm0 -l one one"
#end

desc "create proto"
task :proto do 
  num_states = 20
  vec_size = 39
  protohmm("_proto", WORDS, num_states, vec_size) # dir, names, dir, ns, vs
end

desc "hcompv"
task :hcompv do
  WORDS.each do |w|
    sh "HCompV -T 15 -m -M _hmm0 -S _script/mfcclist0 _proto/#{w}"
  end
end

desc "herest"
task :herest do
  sh "HERest -T 7 -L _label_ph -S _script/mfcclist0 -d _hmm0 -M _hmm1 -C config/config.herest config/models"
  # output : _hmm1/newMacros
end

desc "wdnet"
task :wdnet do
  sh "HParse config/gram _script/wdnet"
end

desc "hvite"
task :hvite do
  sh "HVite -H _hmm1/newMacros -S _script/mfcclist1 -L _label -w _script/wdnet -i _recout.mlf config/dict config/models"
end

desc "hresults"
task :hresults do
  sh "HResults -L _label_wd config/models _recout.mlf"
end

