#!/bin/bash
data_folder="/Users/george/Data/rtfMRI/August/subjects/preprocessed/dmn"
func_folder="/Users/george/Data/rtfMRI/August/subjects/intermediary"
trans_folder="/Users/george/Data/rtfMRI/August/subjects/transformations"
output_folder="/Users/george/Data/rtfMRI/August/subjects/preprocessed/dmn/transformed_dmn_maps"
subjid=(2 3 4 5 6 7 8 9 10)
rests=(1 2)
runs=(1 2 3 4 5)
dmn_seeds=(1 2)

cd $data_folder

for s in "${subjid[@]}"
do
    # T1 to MNI
#    flirt -in subject${s}_t1_bet -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain -out ${trans_folder}/subject${s}_t12mni -omat ${trans_folder}/subject${s}_t12mni.mat -dof 12

    for r in "${runs[@]}"
    do
        if [ ! -f ${func_folder}/subject${s}_run${r}_mc.nii.gz ]; then
            echo 'Missing DMN map for subject'${s}' rest '${rest_num}
            continue
        else
            for rest_num in "${rests[@]}"
            do
                for seed in "${dmn_seeds[@]}"
                do

                    if [ ! -f ${data_folder}/subject${s}_rest${rest_num}_dmn${seed}.nii.gz ]; then
                        echo 'Missing DMN map for subject${s} rest ${rest_num}'
                        continue
                    else
                    cd $trans_folder
                    # generate rest func -> run func rot. matrix
                    convert_xfm -omat subject${s}_rest${rest_num}_dmn${seed}_2run${r}_inverse.mat -concat subject${s}_run${r}_t12func.mat subject${s}_rest${rest_num}_func2t1.mat
                    convert_xfm -omat subject${s}_rest${rest_num}_dmn${seed}_2run${r}.mat -inverse subject${s}_rest${rest_num}_dmn${seed}_2run${r}_inverse.mat

                    cd $data_folder

                    flirt -in subject${s}_rest${rest_num}_dmn${seed} -ref ${func_folder}/subject${s}_run${r}_mc.nii.gz -applyxfm -init ${trans_folder}/subject${s}_rest${rest_num}_dmn${seed}_2run${r}.mat -out ${output_folder}/subject${s}_rest${rest_num}_dmn${seed}_IN_run${r}
                    fi
                done
            done
        fi
    done
done