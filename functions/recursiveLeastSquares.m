function idtf = recursiveLeastSquares(U,Y,Ts,num_zeros,num_poles,option)
%RECURSIVELEASTSQUARES Identify the system parameters for a given system
% input and output using recursive least squares method.
%
% The system Transfer Function is as in the following form:
%
%         z^-d * (bo + b1*z^-1 + b2*z^-2 + ... + b_nb*z^-nb)
% G(z) =  ---------------------------------------------------
%                1 + a1*z^-1 + ... + a_na*z^-na
%
% idtf = RECURSIVELEASTSQUARES(U,Y) identifies discrete-time system's tf
%   
%
% idtf = RECURSIVELEASTSQUARES(U,Y,num_zeros,num_poles) returns 
% estimated parameters for a model of a specified order.
%
% idtf = RECURSIVELEASTSQUARES(U,Y, 'PlotConv', False)
% turns off plotting of parameters convergence.
%
% idtf - structure array with following fields:
%        Numerator - row vector of numerator's polynomial coefficients;
%        Denominator - row vector of denominator's polynomial coefficients;
%        Variable - tf display variable;
%        IODelay - transport delay;
%        Structure - output system model;
%        Ts - sampling time;

    arguments
        U                    (:,1) double {mustBeNumeric, mustBeReal}
        Y                    (:,1) double {mustBeNumeric, mustBeReal}
        Ts                   (1,1) double {mustBeNumeric, mustBeReal}
        num_zeros            (1,1) double {mustBeNumeric, mustBeReal} = 1
        num_poles            (1,1) double {mustBeNumeric, mustBeReal, ...
                              mustBeGreaterThanOrEqual(num_poles,num_zeros)} ...
                              = 1
        option.PlotConv      (1,1) logical = true
    end
   
    nu = num_poles + num_zeros;

    %% Initial conditions
    theta_old   = zeros(nu, 1);                  % Initial Parameters Estimate
    P_old       = 10^6 * eye(nu, nu);            % Initial Covariance Matrix
    Z           = zeros(nu, length(U));          % Allocate memory for data matrix
    a           = zeros(num_poles, length(U));   % Allocate memory for poles 
    b           = zeros(num_zeros, length(U));   % Allocate memory for zeros

    %% find D
    if find(Y > 1,1) > 1
        % -2 correction for time starting in 0 and last element < 1
        D = find(Y > 1,1)-2;         
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
        
        %% Estimation 
        % vector of auxiliary variables - filtered vector from data
        epsilon  = y(n) - Z(:,n)' * theta_old;
        gamma    = 1 + Z(:,n)' * P_old * Z(:,n);            % scalar
        % gain of filter in current step
        L        = gamma \ P_old * Z(:,n);                  
        % update covariace matrix
        P        = P_old - gamma \ P_old * Z(:,n) * Z(:,n)' * P_old;
        % update parameter estimate
        theta    = theta_old + L * epsilon;
        
        P_old = P;
        theta_old = theta;

        % Estimated System Parameters
        a(:,n)   = theta(1:num_poles);
        b(:,n)   = theta(num_poles+1:end);
       
    end           
    
    %% Plot
    % Check the estimated T.F.
    y_est = lsim(tf(b(:,end)',[1 a(:,end)'],Ts,'iodelay',D,'variable','z^-1'),U);
    % Compare the actual and estimated systems outputs
    f = figure;
    f.Position = [100 100 960 540];
    
    grid on 
    hold on
    
    plot(Y(1:end), '--', 'LineWidth', 2)
    plot(y_est(1:end), '-', 'LineWidth', 2)
    
    xlabel('Sample time')
    ylabel('Response')
    title([num2str(num_poles),'. Order Systems Model'], 'FontWeight','Normal')
    legend('Systems real measurement', ...
           [num2str(num_poles), ...
           '. Order Systems Model']) 
    
    if option.PlotConv
        
        % Convergence of parameters
        f = figure;
        f.Position = [100 100 960 540];
        hold on
        
        for m = 1:size(a)
            plot(a(m,:), 'LineWidth', 2)
            yline(a(m,end),'--','color','k')
            
            grid on
            title('Parameter convergence a_i', 'FontWeight','Normal')
            xlabel('Sample time')
            ylabel('Parameter Value')
            
            legend_names{m*2-1} = append('a_',num2str(m));
            legend_names{m*2} = '';
        end
        legend(legend_names)
        
        f = figure;
        f.Position = [100 100 960 540];
        hold on
        
        clear legend_names
        for m = 1:size(b)
            plot(b(m,:), 'LineWidth', 2)
            yline(b(m,end),'--','color','k')
            
            grid on
            title('Parameter convergence b_i', 'FontWeight','Normal')
            xlabel('Sample time')
            ylabel('Parameter Value')
            
            legend_names{m*2-1} = append('b_',num2str(m));
            legend_names{m*2} = '';
        end
        legend(legend_names)
        
    end
    
    %% Returns
    idtf.SysDT          = tf(b(:,end)',[1 a(:,end)'],Ts, ...
                             'iodelay',D, ...
                             'variable','z^-1');
    idtf.NumDT          = b(:,end)';
    idtf.DenDT          = [1 a(:,end)'];
    idtf.Ts             = Ts;
    idtf.IODelay        = D;
    idtf.Variable       = 'z^-1';
    idtf.SysCT          = d2c(idtf.SysDT);
    idtf.NumCT          = cell2mat(idtf.SysCT.Numerator);
    idtf.DenCT          = cell2mat(idtf.SysCT.Denominator);
    [z,p,k]             = zpkdata(idtf.SysCT);
    idtf.SysZPK         = zpk(z,p,k,'DisplayFormat','time constant');
    %idtf.T              = 1/damp(idtf.SysCT);
    %idtf.K             = b(:,end) / (1-exp(-Ts/idtf.T));
    
    
    
end
