addpath('src');
mkdir('output');

MA_data=['data' filesep 'MA' filesep];
YA_data=['data' filesep 'YA' filesep];
MA_output=['output' filesep 'MA.csv'];
YA_output=['output' filesep 'YA.csv'];

filtro_frequencia=10; %low pass filter 10Hz;
D_min=0.0001;         %minimum displacement of the movement element   (m)
T_min=0.1;            %minimum duration of the movement element       (s)
V_min=0.001;          %minimum average speed of the movement element  (m/s)

MED_balance(MA_data,MA_output,0,filtro_frequencia,D_min,T_min,V_min);
MED_balance(YA_data,YA_output,1,filtro_frequencia,D_min,T_min,V_min);