%% Init Workspace
close all
clear all

addpath('functions\')

% Init plot object properties
set(0, 'DefaultLineLineWidth', 1.2, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 20, 'DefaultTextFontName', 'Calibri')

%% Import dataset with columns - t (timestamp), u (manipulated), y (measured)
uiimport

% Assign timestamp, manipulated and measured data into variables
t = IDdata.t;
u = IDdata.u;
y = IDdata.y;

%% Plot input data
f = figure;
f.Position = [100 100 960 540];
subplot(2,1,1)
plot(t, y)
grid on
ylabel('Calibrated Production Rate [ton/h]')
title('Influence of Catalyst Flow on Polypropylene Production Rate', 'FontWeight','Normal')
subplot(2,1,2)
plot(t, u)
grid on
xlabel('Time [min]')
ylabel('Catalyst Flow [kg/h]')

%% Extract data within specified period
%data = setPeriod(t,u,y, 'StartDate', "01.07.2021 17:30:00", 'EndDate', "02.07.2021 9:3:23");
data = setPeriod(t,u,y);

%% Data centralization, normalization and averaging
% last three arguments specify restrictions on input data (see ...
% help preprocessData
[u_mean, y_mean, idx] = preprocessData(data, 30, 50, 90);

%% Identify system parameters of the specified order 
[a,b,D] = recursiveLeastSquares(u_mean, y_mean, 1, 1);

%% Evolution of Gain and Time Constant of the 1st order system
Ts = 1;
T = -Ts/log(abs(a(end)));
K = b(end) / (1-exp(-Ts/T));

f = figure;
f.Position = [100 100 960 540];
plot(-Ts./log(abs(a)))
grid on
xlabel('Number of Measurements')
ylabel('Time Constant [min]')
title('Time Constant Convergence', 'FontWeight','Normal')

f = figure;
f.Position = [100 100 960 540];
plot(b ./ (1-exp(-Ts./(-Ts./log(abs(a))))))
grid on
xlabel('Number of Measurements')
ylabel('Gain')
title('Gain Convergence', 'FontWeight','Normal')

%% Plot output
num = b(:,end)';
den = [1 a(:,end)'];

K_manual = 9.18;    % modify to see how well manual tunned model performed
T_manual = 20;      % modify to see how well manual tunned model performed
ai = -exp(-Ts/T_manual);
bi =  K_manual * (1 - exp(-Ts/T_manual));


f = figure;
f.Position = [100 100 960 540];

subplot(2,1,1)
hold on
grid on
ylabel('Calibrated Production Rate [ton/h]')
title('Influence of Catalyst Flow on Polypropylene Production Rate', 'FontWeight','Normal')

plot(t, y)
y_one = lsim(tf(num,den, Ts, 'iodelay', D, 'variable', 'z^-1'), u-u(1)) + y(1);
y_manual = lsim(tf(bi, [1 ai], Ts, 'iodelay', D, 'variable', 'z^-1'), u-u(1)) + y(1);
plot(t, y_one)
plot(t, y_manual)
legend('Dáta', 'S-R CH model', 'S-R CH model identified manually')
subplot(2,1,2)
plot(t, u)
grid on
xlabel('Time [min]')
ylabel('Catalyst Flow Rate [kg/h]')

%% Plot model with various time constants
num = b(:,end)';
den = [1 a(:,end)'];

f = figure;
f.Position = [100 100 960 540];
hold on
grid on
title('Comparison of Models with Various Time Constants', 'FontWeight','Normal')
xlabel('Time [min]')
ylabel('Calibrated Production Rate [ton/h]')
ylim([28,37])
plot(y);
plot(lsim(tf(num,den, Ts, 'iodelay', D, 'variable', 'z^-1'),u-u(1)) + y(1))

for Ti = 10:10:30
    ai = -exp(-Ts/Ti);
    bi =  K * (1 - exp(-Ts/Ti));
    
    plot(lsim(tf(bi, [1 ai], Ts, 'iodelay', D, 'variable', 'z^-1'),u-u(1)) + y(1))
    legend_names{Ti/10} = append('Ti = ', num2str(Ti), ' min');
end

legend(['IO Data', 'Step-Response Characteristics', legend_names])

%% Plot model with various gains
num = b(:,end)';
den = [1 a(:,end)'];

f = figure;
f.Position = [100 100 960 540];
hold on
grid on
title('Comparison of Models with Various Gains', 'FontWeight','Normal')
xlabel('Time [min]')
ylabel('Calibrated Production Rate [ton/h]')
plot(y);
plot(lsim(tf(num,den, Ts, 'iodelay', D, 'variable', 'z^-1'),u-u(1)) + y(1))

for Ki = 8:2:12
    ai = -exp(-Ts/T);
    bi =  Ki * (1 - exp(-Ts/T));
    
    plot(lsim(tf(bi, [1 ai], Ts, 'iodelay', D, 'variable', 'z^-1'),u-u(1)) + y(1))
    legend_names{Ki/2-3} = append('K = ', num2str(Ki), '');
end

legend(['IO Data', 'Step-Response Characteristics', legend_names])

%% Simulation
T_regulation = 15;

T_process = T;

temp = sim('imc.slx');
CV(:,1) = temp.ScopeData1(:,2);
PV(:,1) = temp.ScopeData1(:,3);

for T_process = 10:10:30
    
temp = sim('imc.slx');
CV(:,T_process/10+1) = temp.ScopeData1(:,2);
PV(:,T_process/10+1) = temp.ScopeData1(:,3);
legend_names_sim{T_process/10} = append('T process: ', num2str(T_process), ' min');
i = i +1;
end

f = figure;
f.Position = [100 100 960 540];
subplot(2,1,1)
plot(PV)
grid on
ylabel('Calibrated Production Rate [ton/h]')
title('Production Rate Control, Comparison of Varying Time Constant of Real Process', 'FontWeight','Normal')
legend([append('T process: ', num2str(T), ' min (match)'), legend_names_sim])
subplot(2,1,2)
plot(CV)
grid on
xlabel('Time [min]')
ylabel('Catalyst Flow Rate [kg/h]')
