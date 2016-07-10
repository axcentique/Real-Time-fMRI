clear
clc

run1_b =[16
39
46
85
101
117
132
157];

run1_r =[8
31
54
108
124];

run2_b =[9
25
40
55
71
86
102
119
136
144];

run2_r =[16
33
48
79
110
127
153
161
169];

run1_b_vol = linspace(0,0,390)';
run1_r_vol = linspace(0,0,390)';
run2_b_vol = linspace(0,0,390)';
run2_r_vol = linspace(0,0,390)';

run1_b_vol(run1_b) = 1
run1_r_vol(run1_r) = 1
run2_b_vol(run2_b) = 1
run2_r_vol(run2_r) = 1