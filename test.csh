#!/bin/csh

############################ set variables ############################
# set directory
set featdir      = baseline_htk 
set htkdir       = htk/htk_3.4/HTKTools
# set network file and hmm list and dictionary
set flags        = "-p 0.0 -s 0.0" # word insertion penalty
set wordlistsp   = lib/words4
set net          = lib/wdnet.net # standard lattice file
set dict         = lib/dict.test
set tset         = f
# set models
set modelname    = $1 #clean
set env          = $2 #psl
# set script file and label file
set scp          = scripts/TS_captcha.scp
# ls ../speechdata/train/${env}/*.wav | sed -e "s/wav\*/mfc/" | cut -d "/" -f 5> $scp
find ../speechdata/testa/${env} -name '*.wav' | sed -e "s/wav\*/mfc/" | cut -d "/" -f 5> $scp
# making label
set now          = `date +%Y%m%d%H%M%S`
#csh makeLbl.csh
#set lbl          = labels/TS_captcha.mlf
#set tmplbl       = misc/tmplbl${now}
#cat $lbl | sed -e "s/\.wav//"> $tmplbl
#cat $tmplbl > $lbl
set lbl          = labels/N1.mlf

# set default parameter
set cfg          = lib/config
set tmp          = misc/tmp_test${now}
set models       = model/${modelname}/hmm1010/models
set macros       = model/${modelname}/hmm1010/macros
set resdir       = result/${modelname}
set rcgdlbl      = ${resdir}/set${tset}-${env}.mlf
set res          = ${resdir}/set${tset}-${env}.res
set log          = ${resdir}/set${tset}-${env}.log
# set temporary file
set tmplist      = misc/tmp_recog${now}.list
# set command
set HVite        = ${htkdir}/HVite
set HResults     = ${htkdir}/HResults
#######################################################################

if (! -d $resdir ) then
  mkdir -p $resdir
endif

cat $scp | cut -d "." -f 1 > $tmp
awk '{printf("'$featdir'/'Mfc'16TS_set'$tset'/'$env'/%s'.mfc'\n", $1)}' $tmp > $tmplist

echo running HVite
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
