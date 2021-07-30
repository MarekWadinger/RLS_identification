function [a,b,D] = recursiveLeastSquares(U,Y,num_zeros,num_poles,option)
%RECURSIVELEASTSQUARES Identify the system parameters for a given system
% input and output using recursive least squares method.
%
% The system Transfer Function is as in the following form:
%
%         z^-d * (bo + b1*z^-1 + b2*z^-2 + ... + b_nb*z^-nb)
% G(z) =  ---------------------------------------------------
%                1 + a1*z^-1 + ... + a_na*z^-na
%
% [a,b,D] = RECURSIVELEASTSQUARES(U,Y) returns estimated parameters and dead-time.
%
% [a,b,D] = RECURSIVELEASTSQUARES(U,Y,num_zeros,num_poles) returns 
% estimated parameters for a model of a specified order.
%
% [a,b,D] = RECURSIVELEASTSQUARES(U,Y, 'PlotConvergence', False)
% turns off plotting of parameters convergence.
%
    arguments
        U                       (:,1) double {mustBeNumeric, mustBeReal}
        Y                       (:,1) double {mustBeNumeric, mustBeReal}
        num_zeros               (1,1) double {mustBeNumeric, mustBeReal} = 1
        num_poles               (1,1) double {mustBeNumeric, mustBeReal, mustBeGreaterThanOrEqual(num_poles,num_zeros)} = 1
        option.PlotConvergence  (1,1) logical = true
    end
   
    nu = num_poles + num_zeros;

    theta_old   = zeros(nu, 1);                  % Initial Parameters
    P_old       = 10^6 * eye(nu, nu);            % Initial Covariance Matrix
    Z           = zeros(nu, length(U));          % Initial Z
    a           = zeros(num_poles, length(U));
    b           = zeros(num_zeros, length(U));

    % find D
    if find(Y > 1,1) > 1
        D = find(Y > 1,1)-2;         % -2 correction for time starting in 0 and last element < 1
    else
        D = 0;
    end

    for n = 1 : length(U)

        u = U(1:n);
        y = Y(1:n);

        for j = 1:(nu)
            if j <= num_poles % terms of y
                if (n-j)<=0
                    Z(j,n) = 0;
                else
                    Z(j,n) = -y(n-j);
                end
            else       % terms of u
                if (n-D-(j-(num_poles+1)))<=0
                    Z(j,n) = 0;
                else
                    Z(j,n) = u(n-D-(j-(num_poles+1)));
                end
            end
        end
        
        % Estimation 
        epsilon  = y(n) - Z(:,n)' * theta_old;
        gamma    = 1 + Z(:,n)' * P_old * Z(:,n);             % scalar
        L        = gamma \ P_old * Z(:,n);                   % gain of filter
        P        = P_old - gamma \ P_old * Z(:,n) * Z(:,n)' * P_old;
        theta    = theta_old + L * epsilon;
        
        P_old = P;
        theta_old = theta;

        % Estimated System Parameters
        a(:,n)   = theta(1:num_poles);
        b(:,n)   = theta(num_poles+1:end);
       
    end           
    
    Ts = 1;
    
    % Plot
    % Check the estimated T.F.
    y_est = lsim(tf(b(:,end)',[1 a(:,end)'],Ts,'iodelay',D,'variable','z^-1'),U);
    %step(tf(b(:,end),[1 a(:,end)],Ts, 'TimeUnit','minutes','InputUnit','minutes','iodelay',D,'variable','z^-1'),length(U))
    % Compare the actual and estimated systems outputs
    f = figure;
    f.Position = [100 100 960 540];
    
    grid on 
    hold on
    
    plot(Y(1:end),'--')
    plot(y_est(1:end),'-')
    
    xlabel('Time [min]')
    ylabel('Calibrated Production Rate [ton/h]')
    title([num2str(num_poles),'. Order Systems Model'], 'FontWeight','Normal')
    legend('Systems real measurement',[num2str(num_poles),'. Order Systems Model']) 
    
    if option.PlotConvergence
        
        % Convergence of parameters
        f = figure;
        f.Position = [100 100 960 540];
        hold on
        
        for m = 1:size(a)
            plot(a(m,:))
            yline(a(m,end),'--','color','k')
            
            grid on
            title('Parameter convergence a_i', 'FontWeight','Normal')
            xlabel('Time [min]')
            ylabel('Parameter')
            
            legend_names{m*2-1} = append('a_',num2str(m));
            legend_names{m*2} = '';
        end
        legend(legend_names)
        
        f = figure;
        f.Position = [100 100 960 540];
        hold on
        
        for m = 1:size(b)
            plot(b(m,:))
            yline(b(m,end),'--','color','k')
            
            grid on
            title('Parameter convergence b_i', 'FontWeight','Normal')
            xlabel('Time [min]')
            ylabel('Parameter')
            
            legend_names{m*2-1} = append('b_',num2str(m));
            legend_names{m*2} = '';
        end
        legend(legend_names)
        
    end
end
