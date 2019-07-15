clc;
clear all;
s2 = serial('COM8','BaudRate',9600)
dur=0.01;
vals=[];
times=[];

fopen(s2);

figureHandle = figure('NumberTitle','off',...
    'Name','Voltage Characteristics',...
    'Color',[0 0 0],'Visible','off');
% Set axes
axesHandle = axes('Parent',figureHandle,...
    'YGrid','on',...
    'YColor',[0.9725 0.9725 0.9725],...
    'XGrid','on',...
    'XColor',[0.9725 0.9725 0.9725],...
    'Color',[0 0 0]);
hold on;
plotHandle = plot(axesHandle,vals,'Marker','.','LineWidth',1,'Color',[0 1 0]);



while(1)
   temp= fscanf(s2,'%f');
   vals(end+1) =temp(1);

    %set(plotHandle,'YData',vals);
    %set(figureHandle,'Visible','on');
    plot(vals)
    drawnow
    pause(dur)
end

fclose(s2);
delete(s2);
clear s2;

