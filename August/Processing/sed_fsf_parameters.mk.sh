#!/bin/bash

#  sed_fsf_parameters.mk.sh
#  
#
#  Created by George on 2/12/13.
#

file=test_design_runs_substitutions

cp session_feat.fsf session_feat_substituted.fsf

while read a b
do
echo $a
echo $b
    sed -e "s|${a}|${b}|g" < session_feat_substituted.fsf > session_feat_substituted.fsf
done < $file
