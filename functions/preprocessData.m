function [u_mean, y_mean, idx] = preprocessData(data, ...
                                                min_interval, ...
                                                max_interval, ...
                                                option)
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
%  [t_mean, u_mean, y_mean, idx] = PREPROCESSDATA(data, max_interval)
%  specifies also max lenght of step response.
%
%  [t_mean, u_mean, y_mean, idx] = PREPROCESSDATA(data, 'Plot', False)
%  turns off plotting of step responses with specified TimeStamp.
%
    arguments
       data 
       % minimal lenght of step response, based on domain knowledge
       min_interval (1,1) double = 0     
       % max cutoff lenght of step response
       max_interval (1,1) double = 0           
       option.Plot (1,1) logical = true
    end
    
    % Transform to column vector
    if isrow(data.u)
        data.t = data.t';
        data.u = data.u';
        data.y = data.y';
    end

    % find indexes step changes of u
    idx = [find(diff(data.u) ~= 0); length(data.u)];
    d_idx = diff(idx);                              % get distance between steps

    if min_interval~=0 , else min_interval = min(d_idx); end
    if max_interval~=0 , else max_interval = max(d_idx); end

    cols = length(d_idx(d_idx >= min_interval));    % ?
    min_common_length = min(d_idx(d_idx >= min_interval));
    
    % Preallocate memory for speed
    if isa(data.t(1),'string')
        t_steps     = NaT(max_interval,cols);
    else
        t_steps     = NaN(max_interval,cols);
    end
    u_steps         = NaN(max_interval,cols);
    y_steps         = NaN(max_interval,cols);
    u_steps_centr   = NaN(max_interval,cols);
    y_steps_centr   = NaN(max_interval,cols);
    u_steps_norm    = NaN(max_interval,cols);
    y_steps_norm    = NaN(max_interval,cols);
    %legend_names    = cell(1,cols);
    
    col = 1;
    dist_prev_step = idx(1) - 1;
    for i = 2:length(idx)
        % Check if signal settled in previous step && 
        if (d_idx(i-1) >=  min_interval) && dist_prev_step >= min_interval
            if d_idx(i-1) > max_interval
                t_steps(1:max_interval, col) = data.t(idx(i-1):idx(i-1) ...
                                                      +max_interval-1);
                u_steps(1:max_interval, col) = data.u(idx(i-1):idx(i-1) ...
                                                      +max_interval-1);
                y_steps(1:max_interval, col) = data.y(idx(i-1):idx(i-1) ...
                                                      +max_interval-1);
            else
                t_steps(1:idx(i)-idx(i-1),col) = data.t(idx(i-1):idx(i)-1);
                u_steps(1:idx(i)-idx(i-1),col) = data.u(idx(i-1):idx(i)-1);
                y_steps(1:idx(i)-idx(i-1),col) = data.y(idx(i-1):idx(i)-1);
            end

            u_steps_centr(:,col) = u_steps(:,col) - u_steps(1,col);
            y_steps_centr(:,col) = y_steps(:,col) - y_steps(1,col);
            
            delta_u = (u_steps(find(~isnan(u_steps(:,col)),1,'last'),col) ...
                        -u_steps(1,col));
            
            u_steps_norm(:,col) = u_steps_centr(:,col)/delta_u;
            y_steps_norm(:,col) = y_steps_centr(:,col)/delta_u;
           
            if isa(data.t(1),'string')
                first_datestr    = datestr(t_steps(1,col));
                end_datestr      = datestr(t_steps(find(~isnat(t_steps(:,col)), ...
                                              1,'last'),col));
                legend_names{col}= append(first_datestr,' - ',end_datestr);
    
            elseif isa(data.t(1),'double')
                first_t       = t_steps(1,col);
                end_t         = t_steps(find(~isnan(t_steps(:,col)),1,'last'),col);
                legend_names{col}= append('Time: ', num2str(first_t),' s - ', ...
                                          num2str(end_t), ' s');
            else
                legend_names{col} = col;
            end

            col = col + 1;
            dist_prev_step = idx(i)-idx(i-1);
        else
            dist_prev_step = idx(i)-idx(i-1);
        end
        
    end
    
    %TODO: when min_common length is bigger than max interval error should
    %be handled
    num_rows = min(min_common_length,max_interval);
    
    u_mean = mean(u_steps_norm(1:num_rows,:),2,'omitnan');
    y_mean = mean(y_steps_norm(1:num_rows,:),2,'omitnan');
    
    if option.Plot
        f = figure;
        f.Position = [100 100 960 540];
        
        plot(y_steps_norm);
        legend(legend_names)
        grid on
        xlabel('Response')
        ylabel('Sample Time')
        title('Mean Step-Response Characteristics', ...
              'FontWeight','Normal')
    end
    
end
