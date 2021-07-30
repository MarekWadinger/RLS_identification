function [u_mean, y_mean, idx] = preprocessData(data, min_interval, prev_interval, max_interval, option)
%PREPROCESSDATA Spits data based on step changes of manipulated variable
%  and conducts centralization and normalization of data returning their
%  mean value.
%
%  [t_mean, u_mean, y_mean, idx] = PREPROCESSDATA(data) returns mean value
%  of step responses extracted from data.
%  
%  [t_mean, u_mean, y_mean, idx] = PREPROCESSDATA(data, min_interval)
%  specifies also minimal lenght of step response.
%
%  [t_mean, u_mean, y_mean, idx] = PREPROCESSDATA(data, prev_interval)
%  specifies also minimal time between step changes.
%
%  [t_mean, u_mean, y_mean, idx] = PREPROCESSDATA(data, max_interval)
%  specifies also max lenght of step response.
%
%  [t_mean, u_mean, y_mean, idx] = PREPROCESSDATA(data, 'Plot', False)
%  turns off plotting of step responses with specified TimeStamp.
%
    arguments
       data table
       min_interval (1,1) double = 30               % minimal lenght of step response
       prev_interval (1,1) double = 50              % time between step changes
       max_interval (1,1) double = 90               % max lenght of step response
       option.Plot (1,1) logical = true
    end
    
    idx = find(diff(data.u) ~= 0);                  % find indexes step changes of u
    d_idx = diff(idx);                              % get distance between steps
    cols = length(d_idx(d_idx >= min_interval));
    min_common_length = min(d_idx(d_idx >= min_interval));
    % Preallocate memory for speed
    t_steps         = NaT(max_interval,cols);
    u_steps         = NaN(max_interval,cols);
    y_steps         = NaN(max_interval,cols);
    u_steps_centr   = NaN(max_interval,cols);
    y_steps_centr   = NaN(max_interval,cols);
    u_steps_norm    = NaN(max_interval,cols);
    y_steps_norm    = NaN(max_interval,cols);
    %legend_names    = cell(1,cols);
    
    col = 1;
    dist_prev_step = idx(1) - 1;
    for i = 1:length(idx)
        if i > 1 && (idx(i)-idx(i-1) >=  min_interval) && dist_prev_step >= prev_interval
            if idx(i)-idx(i-1) > max_interval
                t_steps(1:max_interval, col) = data.t(idx(i-1):idx(i-1)+max_interval-1);
                u_steps(1:max_interval, col) = data.u(idx(i-1):idx(i-1)+max_interval-1);
                y_steps(1:max_interval, col) = data.y(idx(i-1):idx(i-1)+max_interval-1);
            else
                t_steps(1:idx(i)-idx(i-1),col) = data.t(idx(i-1):idx(i)-1);
                u_steps(1:idx(i)-idx(i-1),col) = data.u(idx(i-1):idx(i)-1);
                y_steps(1:idx(i)-idx(i-1),col) = data.y(idx(i-1):idx(i)-1);
            end

            u_steps_centr(:,col) = u_steps(:,col) - u_steps(1,col);
            y_steps_centr(:,col) = y_steps(:,col) - y_steps(1,col);
            
            delta_u = (u_steps(find(~isnan(u_steps(:,col)),1,'last'),col)-u_steps(1,col));
            
            u_steps_norm(:,col) = u_steps_centr(:,col)/delta_u;
            y_steps_norm(:,col) = y_steps_centr(:,col)/delta_u;
            
            first_datestr       = datestr(t_steps(1,col));
            end_datestr         = datestr(t_steps(find(~isnat(t_steps(:,col)),1,'last'),col));
            legend_names{col}   = append(first_datestr,' - ',end_datestr);
            
            col = col + 1;
            dist_prev_step = idx(i)-idx(i-1);
        elseif i > 1
            dist_prev_step = idx(i)-idx(i-1);
        end
        
    end
    
    u_mean = mean(u_steps_norm(1:min_common_length,:),2,'omitnan');
    y_mean = mean(y_steps_norm(1:min_common_length,:),2,'omitnan');
    
    if option.Plot
        f = figure;
        f.Position = [100 100 960 540];
        
        plot(y_steps_norm);
        legend(legend_names)
        grid on
        xlabel('Time [min]')
        ylabel('Calibrated Production Rate [ton/h]')
        title('Step-Response Characteristics of a Polypropylene Production', 'FontWeight','Normal')
    end
    
end
