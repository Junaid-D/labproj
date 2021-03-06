function x = initialize ()

% Copyright 2014 The MathWorks, Inc.
%%%https://www.mathworks.com/matlabcentral/fileexchange/46775-arduino-serial-data-acquisition
%% Create serial object for Arduino
s = serial('COM7'); % change the COM Port number as needed
%% Connect the serial port to Arduino
s.InputBufferSize = 50; % read only one byte every time
s.Terminator = 'LF'
s
 return s
end



%% Create a figure window to monitor the live data
Tmax = 10; % Total time for data collection (s)
figure,
grid on,
xlabel ('Time (s)'), ylabel('Data '),
axis([0 Tmax+1 -10 300]),

ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                          'Callback', @(x,v) click(x,v) );
%% Read and plot the data from Arduino

datasets=3;
dctr=0;


data = [datasets,1];
detect = false;
Fs=125;

Ts = 1/Fs; % Sampling time (s)
i = 0;
data = 0;
t = 0;
tic % Start timer


buds={};

while (1)
    i = i + 1;
    %% Read buffer data
      
    for j = 1:datasets
        
        if(s.BytesAvailable>1)
            asd = 0;
            str = fgetl(s);
            buds{end+1}=str;

            asd = str2num(str);
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
        line([t(i-1) t(i)],[data(2,i-1) data(2,i)],'Color','red')
        line([t(i-1) t(i)],[data(3,i-1) data(3,i)],'Color','blue')
        
       
        if (data(1,i-1)<data(1,i))
            
            line([t(i) t(i)],[data(3,i) data(3,i)],'Color','magenta','Marker','*')
        end
        
        drawnow
        axis auto
    end
    
  if isClicked
    disp('Loop stopped by user');
    break;
  end
    
end
fclose(s);


function [] = click(PushButton, EventData)
    global isClicked;
   isClicked =true;
end

