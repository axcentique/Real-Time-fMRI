data_folder="/Users/george/Data/rtfMRI/August/subjects"
trans_folder="transformations"
output_folder="intermediary"
subjid=(1 2 3 4 5 6 7 8 9 10)
rests=(1 2)
runs=(1 2 3 4 5)

cd $data_folder

for s in "${subjid[@]}"
do
    # T1 to MNI
    flirt -in subject${s}_t1_bet -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain -out ${trans_folder}/subject${s}_t12mni -omat ${trans_folder}/subject${s}_t12mni.mat -dof 12

    for r in "${rests[@]}"
    do
        cd $data_folder
        if [ ! -f ${output_folder}/subject${s}_rest${r}_mc.nii.gz ]; then
            continue
        else
        # func to T1
            flirt -in ${trans_folder}/subject${s}_rest${r}_mc_bet -ref subject${s}_t1_bet -out ${trans_folder}/subject${s}_rest${r}_func2mni -omat ${trans_folder}/subject${s}_rest${r}_func2t1.mat -dof 12
        cd ${data_folder}/${trans_folder}
        # generate MNI -> functional rot. matrix
            convert_xfm -omat subject${s}_rest${r}_func2mni.mat -concat subject${s}_t12mni.mat subject${s}_rest${r}_func2t1.mat
            convert_xfm -omat subject${s}_mni2func.mat -inverse subject${s}_rest${r}_func2mni.mat

        ##WIP    flirt -in ~/Data/rtfMRI/MNI_PCC_precuneus

            std2imgcoord ../dmn_seed_points.txt -img ../subject${s}_rest${r}  -std /usr/local/fsl/data/standard/MNI152_T1_2mm_brain -xfm subject${s}_rest${r}_func2mni.mat -vox > subject${s}_rest${r}_dmn_seeds.txt
        fi
    done
done