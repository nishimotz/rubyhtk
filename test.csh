#!/bin/csh

############################ set variables ############################
# set directory
set envdir       = /lab/common/src/r-tanemura/SPCAPTCHA/env
set datadir      = /lab/common/src/r-tanemura/SPCAPTCHA/speechdata

set featdir      = ${envdir}/baseline_htk 
set htkdir       = /usr/local/bin
# set network file and hmm list and dictionary
set flags        = "-p 0.0 -s 0.0" # word insertion penalty
set wordlistsp   = ${envdir}/lib/words4
set net          = ${envdir}/lib/wdnet.net # standard lattice file
set dict         = ${envdir}/lib/dict.test
set tset         = f
# set models
set modelname    = $1 #clean
set env          = $2 #psl

echo "modelname ${modelname}"
echo "env ${env}"

# set script file and label file
mkdir -p scripts
set scp          = scripts/TS_captcha.scp

# ls ../speechdata/train/${env}/*.wav | sed -e "s/wav\*/mfc/" | cut -d "/" -f 5> $scp
echo "finding ${datadir}/testa/${env}"
find ${datadir}/testa/${env} -name '*.wav' | sed -e "s/wav/mfc/" | ruby -n -e 'puts $_.chomp.split(/\//)[-1]' > $scp

# making label
set now          = `date +%Y%m%d%H%M%S`
#csh makeLbl.csh
#set lbl          = labels/TS_captcha.mlf
#set tmplbl       = misc/tmplbl${now}
#cat $lbl | sed -e "s/\.wav//"> $tmplbl
#cat $tmplbl > $lbl
set lbl          = ${envdir}/labels/N1.mlf

# set default parameter
set cfg          = ${envdir}/lib/config
set tmp          = misc/tmp_test${now}
set models       = ${envdir}/model/${modelname}/hmm1010/models
set macros       = ${envdir}/model/${modelname}/hmm1010/macros

mkdir -p result
set resdir       = result/${modelname}
set rcgdlbl      = ${resdir}/set${tset}-${env}.mlf
set res          = ${resdir}/set${tset}-${env}.res
set log          = ${resdir}/set${tset}-${env}.log
# set temporary file
mkdir -p misc
set tmplist      = misc/tmp_recog${now}.list
# set command
set HVite        = ${htkdir}/HVite
set HResults     = ${htkdir}/HResults
#######################################################################

if (! -d $resdir ) then
  mkdir -p $resdir
endif

# wc $scp
# echo "scp = $scp"
cat $scp | cut -d "." -f 1 > $tmp
# awk '{printf("'$featdir'/'Mfc'16TS_set'$tset'/'$env'/%s'.mfc'\n", $1)}' $tmp 
# awk '{printf("'$featdir'/'Mfc'16TS_set'$tset'/'$env'/%s'.mfc'\n", $1)}' $tmp >$tmplist
# /lab/common/src/r-tanemura/SPCAPTCHA/env/baseline_htk/Mfc16TS_setf/clean1/MBN_612Z781A.mfc
set prefix = "${featdir}/Mfc16TS_set${tset}/${env}/"
set ruby_script = "puts '${prefix}' + $_.chomp + '.mfc'"
echo $ruby_script

cat $scp | cut -d "." -f 1 | ruby -n -e $ruby_script
# > $tmplist

echo running HVite
echo "HVide options : -H $macros -H $models -S $tmplist -C $cfg -l '*' -i $rcgdlbl $flags $dict $wordlistsp"
$HVite -T 1 -D\
       -H $macros\
       -H $models\
       -S $tmplist\
       -C $cfg\
       -w $net\
       -l '*'\
       -i $rcgdlbl\
          $flags\
          $dict\
          $wordlistsp\
       >& $log

echo running HResults #$lbl $wordlistsp $rcgdlbl
$HResults -e "???" sil\
          -e "???" sp\
          -I $lbl\
             $wordlistsp\
             $rcgdlbl\
           > $res
rm -f $tmplist $tmp
