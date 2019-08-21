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

outputFolder = uigetdir();

str = '';
ctr = 1;
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
%     plot(time,sig);
%     
%     plot(manDetects(:,1),manDetects(:,2),'xk','MarkerSize',20);
%     
%     plot(time(lk),pk,'>m','MarkerSize',10);
%     
%     plot(detPoints/1000,valAtDetPoints,'g<','MarkerSize',10);
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

    savename = strcat(attrList(i).filename(1:end-4),'.pdf');
 %   saveas(gcf,fullfile(outputFolder,savename));

    
    l1 =  '\begin{figure}[H]'
    l2 = '\centering'
    l3 = strcat(' \includegraphics[width = 0.7\columnwidth]{raws/',savename,'}');
    l4 = strcat('\caption{Test results for',{' '},attrList(i).filename(1:end-4),'.}');
    l5 = strcat('\label{fig:t',num2str(ctr),'}');
    l6 = '\end{figure}';
    close
    
    str = strcat(str , l1 ,newline ,l2 ,newline ,l3 ,newline ,l4 ,newline ,l5 , newline ,l6 , newline);
    
end

