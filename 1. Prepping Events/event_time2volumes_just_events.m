%% volumize, on/post-event
clear
clc

run1 =[9
17
25
32
40
47
55
64
71
79
86
94
102
109
118
125
133
142
150
158
166];

run2 =[10
17
26
34
41
49
56
65
72
80
87
96
103
111
120
128
137
145
154
162
170];

run1 = run1 - 1;
run2 = run2 - 1;

run1_vol = linspace(0,0,195)';
run2_vol = linspace(0,0,195)';

run1_vol(run1) = 1;
run2_vol(run2) = 1;

csvwrite('../run1.txt',run1_vol)
csvwrite('../run2.txt',run2_vol)

%% 3 columns, pre-event

run1 =[9
17
24
32
40
47
55
63
71
78
85
93
102
109
118
125
133
141
149
158
165];

run2 = [9
17
26
34
41
49
56
64
72
80
87
95
103
111
120
128
137
145
154
162
170];

csvwrite('../run1.txt',run1_vol)
csvwrite('../run2.txt',run2_vol)