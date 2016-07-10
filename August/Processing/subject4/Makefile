RUNS=$(wildcard run*.nii.gz)
RESTS=$(wildcard rest*.nii.gz)

RUN_TEMPLATE=$(wildcard ../*run*.fsf)
REST_TEMPLATE=$(wildcard ../*rest*.fsf)

#feats=$(RUNS:%.fsf=%.feat)

#all: $(feats)

session_feat_%.fsf: %.nii.gz
#		rm -rf session_feat_$*.fsf ;\
#		in_scan=$(pwd)/$^ ;\
#		out_feat=$(pwd)/$* ;\
        sed "s|output_feat_dir|${pwd}/$*|g" -e "s|input_scan_session|${pwd}/$^|g" ../session_feat_$*.fsf  > $@

#design_%.feat: design_%.fsf
#        rm -rf design_$*.feat ;\                                                
#        feat design_$*.fsf




