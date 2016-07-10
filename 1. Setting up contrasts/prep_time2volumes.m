clear
clc

run1.event = [9
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

run2.event = [10
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

run1.prep.start =[6
15
22
30
37
45
53
60
69
76
84
91
99
107
115
123
131
138
147
155
163];

run1.prep.end =[9
17
24
32
40
47
55
63
71
78
86
93
102
109
118
125
133
141
149
158
166];


run2.prep.start =[6
15
23
31
39
47
54
61
70
78
85
92
101
108
117
125
134
142
151
160
168];

run2.prep.end =[9
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

run_length = 195;

run1_prep_vol = linspace(0,0,run_length)';
run2_prep_vol = linspace(0,0,run_length)';

for p = 1:length(run1.prep.start)
    run1_prep_vol(run1.prep.start(p):run1.prep.end(p)) = 1;
end

for p = 1:length(run2.prep.start)
    run2_prep_vol(run2.prep.start(p):run2.prep.end(p)) = 1;
end

% csvwrite('../run1_prep.txt',run1_prep_vol)
% csvwrite('../run2_prep.txt',run2_prep_vol)

run1.numEvents = numel(run1.event);
run2.numEvents = numel(run2.event);

run1.rest.start = [1; run1.event+2];
run1.rest.end = [run1.prep.start-1; run_length];

run2.rest.start = [1; run2.event+2];
run2.rest.end = [run2.prep.start-1; run_length];

run1_rest_vol = linspace(0,0,195)';
run2_rest_vol = linspace(0,0,195)';

for p = 1:length(run1.rest.start)
    run1_rest_vol(run1.rest.start(p):run1.rest.end(p)) = 1;
end

for p = 1:length(run2.rest.start)
    run2_rest_vol(run2.rest.start(p):run2.rest.end(p)) = 1;
end

csvwrite('../run1_rest.txt',run1_rest_vol)
csvwrite('../run2_rest.txt',run2_rest_vol)











