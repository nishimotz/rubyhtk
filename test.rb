#!/usr/bin/ruby

############################ set variables ############################
# set directory
envdir       = "/lab/common/src/r-tanemura/SPCAPTCHA/env"
datadir      = "/lab/common/src/r-tanemura/SPCAPTCHA/speechdata"

featdir      = "#{envdir}/baseline_htk"
htkdir       = "/usr/local/bin"
# set network file and hmm list and dictionary
flags        = "-p 0.0 -s 0.0" # word insertion penalty
wordlistsp   = "#{envdir}/lib/words4"
net          = "#{envdir}/lib/wdnet.net" # standard lattice file
dict         = "#{envdir}/lib/dict.test"
tset         = 'f'

# models
modelname    = ARGV[0] #clean
env          = ARGV[1] #psl

puts "modelname #{modelname}"
puts "env #{env}"

# script file and label file
system "mkdir -p scripts"
scp = "scripts/TS_captcha.scp"

# ls ../speechdata/train/#{env}/*.wav | sed -e "s/wav\*/mfc/" | cut -d "/" -f 5> $scp
puts "finding #{datadir}/testa/#{env}"

File.open(scp, "w") do |outfile|
  File.popen("find #{datadir}/testa/#{env} -name '*.wav' | sed -e \"s/wav/mfc/\"").each do |f|
    outfile.puts f.chomp.split(/\//)[-1]
  end
end

# making label
now          = Time.now.strftime("%Y%m%d%H%M%S")
lbl          = "#{envdir}/labels/N1.mlf"

# default parameter
cfg          = "#{envdir}/lib/config"
tmp          = "misc/tmp_test#{now}"
models       = "#{envdir}/model/#{modelname}/hmm1010/models"
macros       = "#{envdir}/model/#{modelname}/hmm1010/macros"

system "mkdir -p result"
resdir       = "result/#{modelname}"
rcgdlbl      = "#{resdir}/set#{tset}-#{env}.mlf"
res          = "#{resdir}/set#{tset}-#{env}.res"
log          = "#{resdir}/set#{tset}-#{env}.log"
# temporary file
system "mkdir -p misc"
tmplist      = "misc/tmp_recog#{now}.list"
# command
HVite        = "#{htkdir}/HVite"
HResults     = "#{htkdir}/HResults"

#######################################################################

system "mkdir -p #{resdir}"

# wc $scp
# echo "scp = $scp"
#cat $scp | cut -d "." -f 1 > $tmp
# awk '{printf("'$featdir'/'Mfc'16TS_set'$tset'/'$env'/%s'.mfc'\n", $1)}' $tmp 
# awk '{printf("'$featdir'/'Mfc'16TS_set'$tset'/'$env'/%s'.mfc'\n", $1)}' $tmp >$tmplist
# /lab/common/src/r-tanemura/SPCAPTCHA/env/baseline_htk/Mfc16TS_setf/clean1/MBN_612Z781A.mfc
prefix = "#{featdir}/Mfc16TS_set#{tset}/#{env}/"
#ruby_script = "puts '#{prefix}' + $_.chomp + '.mfc'"
#echo $ruby_script

File.open(tmplist, "w") do |outfile|
  File.open(scp).each do |line|
    outfile.puts prefix + line.chomp.split(/\./)[0] + '.mfc'
  end
end

cmd = "#{HVite} -T 1 -D -H #{macros} -H #{models} -S #{tmplist} -C #{cfg} -w #{net} -l '*' -i #{rcgdlbl}                #{flags} #{dict} #{wordlistsp} >& #{log}"
puts cmd
system cmd

cmd = "#{HResults} -e \"???\" sil -e \"???\" sp -I #{lbl} #{wordlistsp} #{rcgdlbl} > #{res}"
system cmd
# system "rm -f #{tmplist} #{tmp}"