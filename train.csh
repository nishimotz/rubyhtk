#!/bin/csh

############################ set variables ############################
# set default parameters    
set cfg           = lib/config
set num_coef      = 39
set mode          = $1
set partype       = MFCC_E_D_A
set parname       = Mfc
# set directory
set featdir       = baseline_htk
set htkdir        = htk/htk_3.4/HTKTools
set tset          = f
#set datadir       = ${parname}16_${mode}TR
set datadir       = ${parname}16TR_set${tset}/${mode}

# set commands
set HCompV        = ${htkdir}/HCompV
set HHEd          = ${htkdir}/HHEd
set HERest        = ${htkdir}/HERest

# Training Data Parameters 
set trainlist     = scripts/train.scp
set num_state     = 18
set proto         = proto.${num_state}
set wordlist      = lib/words3
set wordlistsp    = lib/words4
set lbl           = labels/train.nosp.mlf
set lblsp         = labels/train.sp.mlf

set silhed        = lib/sil1.hed
set mixup1        = lib/mixup1.hed
set mixup2        = lib/mixup2.hed
set mixup3        = lib/mixup3.hed

set progdir       = prog
# ----------------------------------------------------------------------
#
# HMM TRAINING
#

### $hmmdir is the root directory of the models
set hmmdir        = model/${mode}

### $tmplist is only a temporary list file
set now       = `date +%Y%m%d%H%M%S`
set tmplist       = ${hmmdir}/tmp_train_${mode}${now}.list
set tmplist2      = ${hmmdir}/tmp_train_${mode}${now}_2.list

if ( ! -d ${hmmdir}/hmm0 ) then
    mkdir -p ${hmmdir}/hmm0
endif

#
# Produce proto HMM
#
perl ${progdir}/mkproto.pl ${num_coef} ${partype} ${num_state} \
    > ${hmmdir}/hmm0/${proto}

#
# Produce seed HMM
# Generate initial HMM "hmmdef" with global data means and variances
# Creates a file "vFloors" containing the global variances times 0.01
#

cat $trainlist | cut -d "/" -f 2 > $tmplist2
awk '{printf("'${featdir}'/'${datadir}'/%s\n", $1);}' \
${tmplist2} > ${tmplist}

if ( "$mode" == "multi" ) then
    awk '{printf("'${featdir}'/'${datadir}'/%s\n", $1);}' \
${trainlist} > ${tmplist}
endif

echo -n "Creating hmm0 models"
$HCompV -T 2 -D -C ${cfg} -o hmmdef -f 0.01 -m -S ${tmplist} \
    -M ${hmmdir}/hmm0 ${hmmdir}/hmm0/${proto} \
    >& ${hmmdir}/hmm0/HCompV.log
echo " ... Seed HMM successfully produced"

perl ${progdir}/macro.pl ${num_coef} ${partype} ${hmmdir}/hmm0/vFloors \
    > ${hmmdir}/hmm0/macros

#
# Creates the file "models" containing the HMM definition
#   of all 11 digits and the silence model
#
perl ${progdir}/models_1mixsil.pl ${hmmdir}/hmm0/hmmdef > ${hmmdir}/hmm0/models

#if (0) then ###comment out

#
# Training of initial models
#

foreach i (1 2 3)
    if (! -d ${hmmdir}/hmm${i} ) then
	mkdir ${hmmdir}/hmm${i}
    endif
    #set j = $((${i} - 1))
    @ j = ${i} - 1
    echo "Creating hmm${i} models"
    #echo "$HERest -T 1 -D -C ${cfg} -I ${lbl} -S ${tmplist} -t 250.0 150.0 1000.0 -H ${hmmdir}/hmm${j}/macros -H ${hmmdir}/hmm${j}/models -M ${hmmdir}/hmm${i} ${wordlist} >& ${hmmdir}/hmm${i}/HERest.log"
    $HERest -T 1 -D -C ${cfg} -I ${lbl} -S ${tmplist} \
	-t 250.0 150.0 1000.0 \
	-H ${hmmdir}/hmm${j}/macros -H ${hmmdir}/hmm${j}/models \
	-M ${hmmdir}/hmm${i} ${wordlist} >& ${hmmdir}/hmm${i}/HERest.log
end

#
# Generating SP model
#
if (! -d ${hmmdir}/hmm10 ) then
    mkdir ${hmmdir}/hmm10
endif
echo -n "Creating hmm10 models"
cp ${hmmdir}/hmm3/macros ${hmmdir}/hmm3/models ${hmmdir}/hmm10
perl ${progdir}/spmodel_gen.pl ${hmmdir}/hmm3/models >> ${hmmdir}/hmm10/models
$HHEd -T 2 -H ${hmmdir}/hmm10/macros -H ${hmmdir}/hmm10/models \
    ${silhed} ${wordlistsp} >& ${hmmdir}/hmm10/HHEd.log
echo " ... SP model fixed"

#
# Training models using label with sp
#
foreach i (1 2 3)
    if (! -d ${hmmdir}/hmm1${i}) then
	mkdir ${hmmdir}/hmm1${i}
    endif
    #set j = $((${i} - 1))
    @ j = ${i} - 1
    echo "Creating hmm1${i} models"
    $HERest -T 1 -C ${cfg} -I ${lblsp} -S ${tmplist} \
	-H ${hmmdir}/hmm1${j}/macros -H ${hmmdir}/hmm1${j}/models \
	-M ${hmmdir}/hmm1${i} ${wordlistsp} \
	>& ${hmmdir}/hmm1${i}/HERest.log
end

#
# Increasing mixtures
#
foreach k (2 3 4)
    #set indir  = ${hmmdir}/hmm$(((${k} - 1) * 10 + 3))
    @ tmp      = (${k} - 1) * 10 + 3
    set indir  = ${hmmdir}/hmm${tmp}
    set outdir = ${hmmdir}/hmm${k}0
    if (! -d ${outdir}) then
	mkdir ${outdir}
    endif
    echo -n "Creating hmm${k}0 models"
    $HHEd -T 2 -H ${indir}/macros -H ${indir}/models \
	-M ${outdir} ${mixup1} ${wordlistsp} >& ${outdir}/HHEd.log
    echo " ... ${k} Gaussians per mixture created"

    foreach i (1 2 3)
	#set indir  = ${hmmdir}/hmm${k}$((${i} - 1))
	@ tmp      = ${i} - 1
	set indir  = ${hmmdir}/hmm${k}${tmp}
	set outdir = ${hmmdir}/hmm${k}${i}
	if (! -d ${outdir} ) then
	    mkdir ${outdir}
	endif
	echo "Creating hmm${k}${i} models"
	$HERest -T 1 -C ${cfg} -I ${lblsp}  -S ${tmplist} \
	    -H ${indir}/macros -H ${indir}/models \
	    -M ${outdir} ${wordlistsp} >& ${outdir}/HERest.log
    end
end

foreach k (5 6 7 8)
    #set indir  = ${hmmdir}/hmm$(((${k} - 1) * 10 + 3)) 
    @ tmp      = (${k} - 1) * 10 + 3
    set indir  = ${hmmdir}/hmm${tmp}
    set outdir = ${hmmdir}/hmm${k}0
    if (! -d ${outdir}) then
	mkdir ${outdir}
    endif
    echo -n "Creating hmm${k}0 models"
    $HHEd -T 2 -H ${indir}/macros -H ${indir}/models \
	-M ${outdir} ${mixup2} ${wordlistsp} >& ${outdir}/HHEd.log
    #echo " ... $(((${k} - 4) * 2 + 4)) Gaussians per mixture created"
    @ tmp      = (${k} - 4) * 2 + 4
    echo " ... $tmp Gaussians per mixture created"

    foreach i (1 2 3)
	#set indir=${hmmdir}/hmm${k}$((${i} - 1)) 
	@ tmp      = ${i} - 1
	set indir  = ${hmmdir}/hmm${k}${tmp}
	set outdir=${hmmdir}/hmm${k}${i}
	if (! -d ${outdir}) then
	    mkdir ${outdir}
	endif
	echo "Creating hmm${k}${i} models"
	$HERest -T 1 -C ${cfg} -I ${lblsp}  -S ${tmplist} \
	    -H ${indir}/macros -H ${indir}/models \
	    -M ${outdir} ${wordlistsp} >& ${outdir}/HERest.log
    end
end

foreach k (9)
    #set indir  = ${hmmdir}/hmm$(((${k} - 1) * 10 + 3)) 
    @ tmp      = (${k} - 1) * 10 + 3
    set indir  = ${hmmdir}/hmm${tmp}
    set outdir = ${hmmdir}/hmm${k}0
    if (! -d ${outdir}) then
	mkdir ${outdir}
    endif
    echo -n "Creating hmm${k}0 models"
    $HHEd -T 2 -H ${indir}/macros -H ${indir}/models \
	-M ${outdir} $mixup3 ${wordlistsp} >& ${outdir}/HHEd.log
    #echo " ... $(((${k} - 8) * 4 + 12)) Gaussians per mixture created"
    @ tmp      = (${k} - 8) * 4 + 12
    echo " ... $tmp Gaussians per mixture created"

    foreach i (1 2 3)
	#set indir  = ${hmmdir}/hmm${k}$((${i} - 1))
	@ tmp      = ${i} - 1
	set indir  = ${hmmdir}/hmm${k}${tmp}
	set outdir = ${hmmdir}/hmm${k}${i}
	if (! -d ${outdir}) then
	    mkdir ${outdir}
	endif
	echo "Creating hmm${k}${i} models"
	$HERest -T 1 -C ${cfg} -I ${lblsp}  -S ${tmplist} \
	    -H ${indir}/macros -H ${indir}/models \
	    -M ${outdir} ${wordlistsp} >& ${outdir}/HERest.log
    end
end

##endif ##comment out

foreach k (10)
    #set indir  = ${hmmdir}/hmm$(((${k} - 1) * 10 + 3))
    @ tmp      = (${k} - 1) * 10 + 3
    set indir  = ${hmmdir}/hmm${tmp}
    set outdir = ${hmmdir}/hmm${k}0
    if (! -d ${outdir} ) then
	mkdir ${outdir}
    endif
    echo -n "Creating hmm${k}0 models"
    $HHEd -T 2 -H ${indir}/macros -H ${indir}/models \
	-M ${outdir} ${mixup3} ${wordlistsp} >& ${outdir}/HHEd.log
    #echo " ... $(((${k} - 8) * 4 + 12)) Gaussians per mixture created"
    @ tmp      = (${k} - 8) * 4 + 12
    echo " ... $tmp Gaussians per mixture created"

    foreach i (1 2 3 4 5 6 7 8 9)# 10)
	echo making..
	#set indir = ${hmmdir}/hmm${k}$((${i} - 1))
	@ tmp      = ${i} - 1
	set indir  = ${hmmdir}/hmm${k}${tmp}
	set outdir = ${hmmdir}/hmm${k}${i}
	if (! -d ${outdir}) then
	    mkdir ${outdir}
	endif
	echo "Creating hmm${k}${i} models"
	$HERest -T 1 -C ${cfg} -I ${lblsp} -S ${tmplist} \
	    -H ${indir}/macros -H ${indir}/models\
	    -M ${outdir} ${wordlistsp} >& ${outdir}/HERest.log
    end
end	
echo "Creating hmm1010 models"
mkdir -p ${hmmdir}/hmm1010
touch ${hmmdir}/hmm1010/stats${mode}
$HERest -T 1 -C ${cfg} -I ${lblsp} -S ${tmplist} \
	-H ${hmmdir}/hmm109/macros -H ${hmmdir}/hmm109/models\
	-s ${hmmdir}/hmm1010/stats${mode}\
	-M ${hmmdir}/hmm1010 ${wordlistsp} >& ${hmmdir}/hmm1010/HERest.log

rm -f $tmplist $tmplist2

