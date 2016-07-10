data_folder="/Users/george/Data/rtfMRI/August/subjects/preprocessed"
output_folder="/Users/george/Data/rtfMRI/August/subjects/filtered"
subjid=(1 2 3 4 5 6 7 8 9 10)
rests=(1 2)
runs=(1 2 3 4 5)

cd $data_folder

for s in "${subjid[@]}"
do
    for r in "${runs[@]}"
    do
        if [ ! -f subject${s}_run${r}_all.nii.gz ]; then
            continue
        else
            fslmaths subject${s}_run${r}_all.nii.gz -bptf 5 -1 ${output_folder}/subject${s}_run${r}_hi_pass_5.nii.gz
        fi
    done
done