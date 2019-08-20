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
    
    x(any(isnan(x), 2), :) = [];
    sig = x(:,2).';
    time = x(:,end).'/1000;
    hold on;
    plot(time,sig);
    
    plot(manDetects(:,1),manDetects(:,2),'xc','MarkerSize',20);
    
    plot(time(lk),pk,'>m','MarkerSize',10);
    
    plot(detPoints/1000,valAtDetPoints,'g<','MarkerSize',10);
    
    set(gca, 'FontName', 'Times');
    xlabel('Time (s)');
    ylabel('Voltage (V)');
    legend('Breath Signal','Breath Detections (Reported)', 'Breath Detections (\textit{findpeaks})','Breath Detections (Manual)','Location','southwest');
    hold off;
    
    savename = strcat(attrList(i).filename(1:end-4),'.pdf');
    saveas(gcf,fullfile(outputFolder,savename));

    l1 =  '\begin{figure}[H]'
    l2 = '\centering'
    l3 = strcat(' \includegraphics[width = \columnwidth]{foldername/',savename,'}');
    l4 = strcat('\caption{Test results for ',attrList(i).filename(1:end-4));
    l5 = strcat('\label{fig:t',num2str(ctr),'}');
    l6 = '\end{figure}';
    close
    
    str = strcat(str , l1 , newline ,l2 ,newline ,l3 ,newline ,l4 ,newline ,l5 , newline ,l6 , newline);
    
end




function out = getAttr(name,folder)

res.name = '';
res.ambient = '';
res.depth = '';
res.rate = '';
res.mask =  '';
res.interrupted = '';
res.orifice = '';
res.filename = name;
res.path = folder;

res.countable = 'False';

strs = strsplit(name(1:end-4),'-');

res.name = strs(1);

if length(strs)== 7
    res.ambient = strs(2);
    res.depth = strs(3);
    res.rate = strs(4);
    res.mask = strs(5);
    res.interrupted = strs(6);
    res.orifice = strs(7);
    res.countable = 'True';

end

if length(strs)== 5
    res.ambient = strs(2);
    res.depth = strs(3);
    res.rate = '';
    res.mask = strs(4);
    res.orifice = strs(5);
    res.countable = 'True';
end

out = res;
end