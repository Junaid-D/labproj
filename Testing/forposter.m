clc;
clear all;

folder = 'Full_test';
list = dir('**/*.csv');
ctr = 0;
Errs = 0;
RRErrTot = 0 ;

thisFolder = pwd();

tmp = struct2cell(list);
names = tmp(1,:);
path = tmp(2,:);
attrList = cellfun(@getAttr,names,path);
attrList = filterby(attrList,'countable','True',1);
attrList = filterby(attrList,'ambient','35',0);
attrList = filterby(attrList,'ambient','23',1);
attrList = filterby(attrList,'orifice','M',1);
attrList = filterby(attrList,'depth','N',1);
attrList = filterby(attrList,'interrupted','Y',0);

attrList = filterby(attrList,'name','M',1);

str = '';
ctr = 1;
hold on;
dettt = {};
for i=1:length(attrList)
    if(contains(attrList(i).path,'ManuallyMarked'))
        continue;
    end
    ctr = ctr+1;
    
    ctr=ctr+1;
    x = csvread(fullfile(attrList(i).path,attrList(i).filename));
    x(any(isnan(x), 2), :) = [];

    sig = x(:,2).';
    time = x(:,end).'/1000;
    %reported
    
    [~,idu] = unique(x(:,3));
    uniqueDetVals = x(idu,:);
    uniqueDetVals = uniqueDetVals(2:end,:);
    
    detPoints = uniqueDetVals(:,3).';
    if(length(detPoints)>1)
        valAtDetPoints = interp1(uniqueDetVals(:,5).',uniqueDetVals(:,2).',detPoints);
    elseif (length(detPoints)>0)
        valAtDetPoints = uniqueDetVals(1,2);
    else
        valAtDetPoints = [];
    end
    dettt{i} = uniqueDetVals;
    
    %findpks
    
    [pk,lk] = findpeaks(sig);
    
    %manual

    path = strcat(thisFolder,'\ManuallyMarked\');
    manualFile = fullfile(path, attrList(i).filename);
    manDetects = csvread(manualFile);
    
    sig = x(:,2).';
    time = x(:,end).'/1000;
    
%     figure('Visible','off');
% 
%     
%     hold on;
 plotname = attrList(i).filename
 plotname = plotname(1:end-4)
    plot(time,sig,'DisplayName',plotname);
        legend('-DynamicLegend')

%     plot(manDetects(:,1),manDetects(:,2),'xk','MarkerSize',20);
%     
%     plot(time(lk),pk,'>m','MarkerSize',10);
%     n
    
    % plot(detPoints/1000,uniqueDetVals(:,2).','g<','MarkerSize',5,'DisplayName',plotname);
%     
%     set(gca, 'FontName', 'Times');
%     xlabel('Time (s)');
%     ylabel('Voltage (V)');
%     legend('Breath Signal','Breath Detections (Reported)', 'Breath Detections ({\it findpeaks})','Breath Detections (Manual)','Location','southwest');
%     hold off;
%     
%     set(gca,'units','centimeters')
%     pos = get(gca,'Position');
%     ti = get(gca,'TightInset');
% 
%     fig = gcf;
%     fig.PaperPositionMode = 'auto';
%     fig_pos = fig.PaperPosition;
%     fig.PaperSize = [fig_pos(3) fig_pos(4)];



    
 
    
end
colors = ['b<' 'b<'];
for i = 1 : 2
    abc = dettt{i};
         b = plot(abc(:,3)/1000,abc(:,2),'b<','MarkerSize',5);
    set(get(get(b,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

end

 abc = dettt{3};
 plot(abc(:,3)/1000,abc(:,2),'b<','MarkerSize',5,'DisplayName','Detected Breaths');


xlabel('Time (s)');
ylabel('Voltage (V)');
%legend('Breath Signal','Breath Detections','Location','southwest');
hold off;

set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');
set(gca, 'FontName', 'Times');
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];




outputFolder = uigetdir();



    savename = 'withdets.pdf';

    saveas(gcf,fullfile(outputFolder,savename));