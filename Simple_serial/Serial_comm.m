clear all;
clc;

% Copyright 2014 The MathWorks, Inc.
%%%https://www.mathworks.com/matlabcentral/fileexchange/46775-arduino-serial-data-acquisition
%% Create serial object for Arduino
s = Bluetooth('HC-05',1); % change the COM Port number as needed
%% Connect the serial port to Arduino
s.InputBufferSize = 1024; % read only one byte every time
s.Terminator = 'CR/LF'
%s.BaudRate = 115200
s
global isClicked;
isClicked = false;


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

ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                          'Callback', @(x,v) click(x,v) );
%% Read and plot the data from Arduino

datasets=5;
dctr=0;


data = NaN(600,datasets);
detect = false;
Fs=125;

Ts = 1/Fs; % Sampling time (s)
i = 0;
data = 0;
t = 0;
tic % Start timer

%clean = fscanf(s);
buds={};
profile on;
tic;
while (1)
    i = i + 1;
    %% Read buffer data
        
           asd = fscanf(s);
           
           p =  sscanf(asd,'%f %f %lu %f %lu');
        
           buds{end+1}=asd;
           %asd = str2num(asd);
        
           for j = 1:datasets
                if length(p) ==datasets
                    data(j,i) = p(j);
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
  
    t(i) = data(end,end)/1000;
    
    t_0 = toc;
    t_1 = t_0;
    while((t_1-t_0)<Ts)
        t_1=toc;
    end
    
    
    %% Plot live data
    if i > 1
        line([t(i-1) t(i)],[data(1,i-1) data(1,i)],'Color','red')
        line([t(i-1) t(i)],[data(2,i-1) data(2,i)],'Color','blue')
        
       
        if (data(3,i-1)<data(3,i))
            
            line([t(i) t(i)],[data(2,i) data(2,i)],'Color','magenta','Marker','*')
        end
        
        drawnow
        axis auto
    end
    
  if isClicked
    disp('Loop stopped by user');
    break;
  end
    
end
disp('sd');
profile viewer
fclose(s);
delete(s);
%clear s;


function [] = click(PushButton, EventData)
    global isClicked;
   isClicked =true;
end


