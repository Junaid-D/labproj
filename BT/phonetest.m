clear all;
clc;

% Copyright 2014 The MathWorks, Inc.
%%%https://www.mathworks.com/matlabcentral/fileexchange/46775-arduino-serial-data-acquisition
%% Create serial object for Arduino
s = serial('COM9'); % change the COM Port number as needed
%% Connect the serial port to Arduino
s.InputBufferSize = 1024; % read only one byte every time
s.Terminator = 'CR/LF'
s.BaudRate = 115200
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


data = [datasets,1];
detect = false;
Fs=125;

Ts = 1/Fs; % Sampling time (s)
i = 0;
data = 0;
t = 0;
tic % Start timer

%clean = fscanf(s);
buds={};

tic;
while (1)
    
    x= fread(s);
    disp(x);
  if isClicked
    disp('Loop stopped by user');
    break;
  end
    
end
disp('sd');
fclose(s);
delete(s);
%clear s;


function [] = click(PushButton, EventData)
    global isClicked;
   isClicked =true;
end

