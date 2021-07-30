%% Plot output
num = b(:,end)';
den = [1 a(:,end)'];

D = 5;
K_best = 9.18;
T_best = 20;
ai = -exp(-Ts/T_best);
bi =  K_best * (1 - exp(-Ts/T_best));

sys = tf(num,den, Ts, 'iodelay', D, 'variable', 'z^-1');
sys_honey = tf(bi, [1 ai], Ts, 'iodelay', D, 'variable', 'z^-1');

f = figure;
f.Position = [100 100 960 540];

subplot(2,1,1)
hold on
grid on
ylabel('Kalibrovaná produkcia [ton/h]')
title('Vplyv prietoku katalyzátora na produkciu polypropylénu', 'FontWeight','Normal')

for i = 1:length(idx)
    if i > 1
        plot(t(idx(i-1):idx(i)), y(idx(i-1):idx(i)), 'Color', [0, 0.4470, 0.7410])
        y_one = lsim(sys, u(idx(i-1):idx(i))-u(idx(i-1))) + mean(y((idx(i-1)-10):idx(i-1)));
        y_honey = lsim(sys_honey, u(idx(i-1):idx(i))-u(idx(i-1))) + mean(y((idx(i-1)-10):idx(i-1)));
        plot(t(idx(i-1):idx(i)), y_one, 'Color', [0.8500, 0.3250, 0.0980])
        plot(t(idx(i-1):idx(i)), y_honey, 'Color', [0.9290, 0.6940, 0.1250])        
    else
        plot(t(1:idx(i)), y(1:idx(i)), 'Color', [0, 0.4470, 0.7410])
        y_one = lsim(sys, u(1:idx(i))-u(1)) + y(1);
        y_honey = lsim(sys_honey, u(1:idx(i))-u(1)) + y(1);
        plot(t(1:idx(i)), y_one, 'Color', [0.8500, 0.3250, 0.0980])
        plot(t(1:idx(i)), y_honey, 'Color', [0.9290, 0.6940, 0.1250])    
    end
end

legend('Dáta', 'PCH modelu', 'PCH modelu identifikovaného prog. Honeywell')
subplot(2,1,2)
plot(t, u)
grid on
xlabel('Čas [min]')
ylabel('Prietok katalyzátora [kg/h]')