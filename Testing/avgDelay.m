clc;
clear all;


list = dir('**/*.csv');
thisFolder = pwd();

ctr = 0;
Errs = 0;
Errs2 = 0;



tmp = struct2cell(list);
names = tmp(1,:);
path = tmp(2,:);

attrList = cellfun(@getAttr,names,path);
attrList = filterby(attrList,'countable','True',1);
attrList = filterby(attrList,'ambient','35',0);
% attrList = filterby(attrList,'ambient','23',0);
% attrList = filterby(attrList,'ambient','7',0);
% attrList = filterby(attrList,'ambient','6',0);
% attrList = filterby(attrList,'ambient','24',0);
% attrList = filterby(attrList,'ambient','25',0);
%attrList = filterby(attrList,'depth','D',1);

closenessThresh = 0.5 ; %sec
avgDel = 0;
dels = [];
stddevs = [];
for i=1:length(attrList)
    if(contains(attrList(i).path,'ManuallyMarked'))
            continue;
    end
    
       
    ctr=ctr+1;
    x = csvread(fullfile(attrList(i).path,attrList(i).filename));

    x(any(isnan(x), 2), :) = [];

    sig = x(:,2).';
    time = x(:,end).'/1000;
    
    detsWStamps=x;

    [~,idu] = unique(detsWStamps(:,3));
    uniqueDetVals = detsWStamps(idu,:);
    uniqueDetVals = uniqueDetVals(2:end,:);
    
    detPoints = uniqueDetVals(:,3).'/1000;
   
    
    path = strcat(thisFolder,'\ManuallyMarked\');
    manualFile = fullfile(path, attrList(i).filename);
    
    manDetects = csvread(manualFile);
    
    manDetTimes = manDetects(:,1).';
    
   
    [matdets,matdetlocs] = findpeaks(sig);
    
    percount  = 0;
    totDel = 0;
    dels = [];
    for j = 1: length(detPoints)
        
        for k = 1: length(matdetlocs)
            if(  (  detPoints(j) - time(matdetlocs(k))  ) <closenessThresh && time(matdetlocs(k))<detPoints(j) )
                percount = percount+1;
                totDel = totDel + detPoints(j) - time(matdetlocs(k)) ;
                dels(end+1) = detPoints(j) - time(matdetlocs(k));
                break;
            end
        end
        
    end
    if(~isnan(totDel/percount))
        dels(end+1) = totDel/percount;
    end
   if(percount > 0)
       stddevs(end+1) = std(dels);
    avgDel  = avgDel + totDel/percount;
   end
end
avgDel/ctr

h= histfit(dels);
 ylabel('Count')
 xlabel('Delay in Breath Detection (s)') 


h(2).LineStyle = '--';

set(gca, 'FontName', 'Times')

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;

fig.PaperSize = [fig_pos(3) fig_pos(4)];
outputFolder = uigetdir();

file = 'hist.pdf';
saveas(gcf,fullfile(outputFolder,file));
close;
