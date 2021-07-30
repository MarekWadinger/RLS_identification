function out_data = setPeriod(time_stamp, manipulated, measured, option)
%SETPERIOD Specify time period of data.
%  out_data = SETPERIOD(time_stamp, manipulated, measured) creates object
%  from arrays of doubles.
%
%  out_data = SETPERIOD(time_stamp, manipulated, measured,
%  'StartDate',"dd.MM.yyyy hh:mm:ss")
%  given specified StartDate returns object without measurements
%  up to given time.
%
%  out_data = SETPERIOD(time_stamp, manipulated, measured,
%  'StartDate',"dd.MM.yyyy hh:mm:ss",'EndDate',"dd.MM.yyyy hh:mm:ss")
%  alse strips measurements after specified EndDate.
%
    arguments 
        time_stamp (:,1) datetime
        manipulated (:,1) double {mustBeNumeric, mustBeReal}
        measured (:,1) double {mustBeNumeric, mustBeReal}
        option.StartDate (1,1) string {mustBeValidDate(option.StartDate, time_stamp)} = ""
        option.EndDate (1,1) string {mustBeValidDate(option.EndDate, time_stamp)}= ""
    end
   
    if option.StartDate == ""
        option.StartDate = time_stamp(1); 
    else
        option.StartDate = datetime(option.StartDate, 'InputFormat','d.M.yyyy H:mm:ss');
    end
    
    if option.EndDate == ""
        option.EndDate = time_stamp(end); 
    else
        option.EndDate = datetime(option.EndDate, 'InputFormat','d.M.yyyy H:mm:ss');
    end

    out_data = table(time_stamp, manipulated, measured, 'VariableNames', {'t','u','y'});
    out_data = out_data(option.StartDate <= out_data.t & out_data.t <= option.EndDate, :);
end


function mustBeValidDate(date, timeseries)
       try
           datetime(date, 'InputFormat','d.M.yyyy H:mm:ss');
       catch
           eid = 'MATLAB:datetime:wrongInput';
           msg = 'Invalid date format, please use format "dd.MM.yyyy hh:mm:ss"';
           throwAsCaller(MException(eid,msg))
       end
       if datetime(date) > timeseries(end)
           eid = 'Date:outOfRange';
           msg = ['Specified date comes after the last Timestamp of provided datetime array. \n' ...
                 'Provide date before: ', sprintf('%s',timeseries(end))];
           throwAsCaller(MException(eid,msg))
       elseif datetime(date) < timeseries(1)
           eid = 'Date:outOfRange';
           msg = ['Specified date comes before the first Timestamp of provided datetime array. \n' ...
                 'Provide date after: ', sprintf('%s',timeseries(1))];
           throwAsCaller(MException(eid,msg))
       end
end
