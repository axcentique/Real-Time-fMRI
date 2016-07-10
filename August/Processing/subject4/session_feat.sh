rests=(1 2)
runs=(1 2 3 4 5)

for r in "${runs[@]}"
do
	if [ ! -f run${r}.nii.gz ]; then
		echo run${r}" doesn't exist"
		continue
	else
	sed -e "s|output_feat_dir|${pwd}/run${r}|g" -e "s|input_scan_session|${pwd}/$^|g" < design_template_4s.fsf > design_s${s}_run${r}_4s.fsf &
fi
done


sed  ../session_feat_$*.fsf  > $@