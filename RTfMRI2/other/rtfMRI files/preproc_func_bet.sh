data_folder="/Users/george/Data/rtfMRI/August/subjects"
output_folder="intermediary"
transform_folder="transformations"
subjid=(1 2 3 4 5 6 7 8 9 10)
rests=(1 2)
runs=(1 2 3 4 5)

cd /${data_folder}/${output_folder}

for s in "${subjid[@]}"
do
    for r in "${rests[@]}"
    do
        if [ ! -f subject${s}_rest${r}_mc.nii.gz ]; then
            continue
        else
            echo "BETing rest#"${r}" of subject#"${s}
            bet subject${s}_rest${r}_mc ../${transform_folder}/subject${s}_rest${r}_mc_bet -R -m &
        fi
    done
    for r in "${runs[@]}"
    do
        if [ ! -f subject${s}_run${r}_mc.nii.gz ]; then
            continue
        else
            echo "BETing run#"${r}" of subject#"${s}
            bet subject${s}_run${r}_mc ../${transform_folder}/subject${s}_run${r}_mc_bet -R -m &
        fi
    done
done
