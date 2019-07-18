% Copyright 2014 The MathWorks, Inc.
%%%https://www.mathworks.com/matlabcentral/fileexchange/46775-arduino-serial-data-acquisition
%% Create serial object for Arduino
s = serial('COM7'); % change the COM Port number as needed
%% Connect the serial port to Arduino
s.InputBufferSize = 20; % read only one byte every time
s.Terminator = 'LF'
s
try
    fopen(s);
catch err
    fclose(instrfind);
    error('Make sure you select the correct COM Port where the Arduino is connected.');
end
%% Create a figure window to monitor the live data
Tmax = 10; % Total time for data collection (s)
figure,
grid on,
xlabel ('Time (s)'), ylabel('Data '),
axis([0 Tmax+1 -10 300]),
%% Read and plot the data from Arduino

datasets=2;
dctr=0;

data = [datasets,1];

Fs=125;

Ts = 1/Fs; % Sampling time (s)
i = 0;
data = 0;
t = 0;
tic % Start timer




while toc<Tmax
    i = i + 1;
    %% Read buffer data
      
    for j = 1:datasets
        
        if(s.BytesAvailable>1)
            asd=fscanf(s,'%d');
        end
        if length(asd)==1
            data(j,i) = asd;
        elseif i>1
           data(j,i) = data(j,i-1);
        else
            data(j,i)=0;
        end

    end
    
    %% Read time stamp
    % If reading faster than sampling rate, force sampling time.
    % If reading slower than sampling rate, nothing can be done. Consider
    % decreasing the set sampling time Ts
    t(i) = toc;
    if i > 1
        T = toc - t(i-1);
        while T < Ts
            T = toc - t(i-1);
        end
    end
    t(i) = toc;
    %% Plot live data
    if i > 1
        line([t(i-1) t(i)],[data(1,i-1) data(1,i)],'Color','red')
        line([t(i-1) t(i)],[data(2,i-1) data(2,i)],'Color','blue')
        drawnow
    end
end
axis 'auto y'
fclose(s);
