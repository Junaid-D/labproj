clc;
clear all;

%folder = '.';
%cd(folder);
list = dir('**/*.csv');
subfolder = pwd();
%cd('..');
thisFolder = pwd();

ctr = 0;
Errs = 0;
Errs2 = 0;
RRErrTot = 0 ;


tmp = struct2cell(list);
names = tmp(1,:);
path = tmp(2,:);
attrList = cellfun(@getAttr,names,path);


attrList = filterby(attrList,'countable','True',1);
 attrList = filterby(attrList,'ambient','35',0);
% attrList = filterby(attrList,'ambient','6',0);
% attrList = filterby(attrList,'ambient','7',0);
% attrList = filterby(attrList,'ambient','30',0);
% attrList = filterby(attrList,'ambient','29',0);
attrList = filterby(attrList,'name','J',0);
attrList = filterby(attrList,'name','M',0);
attrList = filterby(attrList,'name','R1',0);
attrList = filterby(attrList,'name','R2',0);
attrList = filterby(attrList,'name','R3',0);
attrList = filterby(attrList,'name','R4',0);
attrList = filterby(attrList,'name','R5',0);

%attrList = filterby(attrList,'name','JAD',1);

mandets = [];
filedets = [];
matdets = [];

for i=1:length(attrList)
    attrs = attrList(i);
   
      if(contains(attrList(i).path,'ManuallyMarked'))
            continue;
      end

    
    ctr=ctr+1;
    x = csvread(fullfile(attrList(i).path,attrList(i).filename));
    x(any(isnan(x), 2), :) = [];
    sig = x(:,2).';
    time = x(:,end).'/1000;
    
    
    
    [tResamp,sigResamp] = interper(time,sig,40);
    
    tunedDets = gradDetector(tResamp,sigResamp,0.1);
    %figure();
    

    split = 5;
    
    sigReshaped = reshape(sigResamp,[],split);
    tReshaped = reshape(tResamp,[],split);
    
    Ts = tResamp(2)-tResamp(1);
    Fs = 1/Ts;
    RRErrs = 0;
    for j = 1 : split
    
    L = length(sigReshaped(:,j));
    Y = fft(sigReshaped(:,j));
    f = Fs*(0:(L/2))/L;
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    [val,index] = max(P1(2:end));

    tStart = tReshaped(1,j);
    tEnd = tReshaped(end,j);
    
    includedTimePts = and(time>= tStart , time<tEnd);
    RRpts = x(:,4).';
    RRpts = RRpts(includedTimePts);
    
    dominantFreq = f(index+1)*60;
    
    avgRR = mean(RRpts(RRpts>0));
    
    txt = strcat('tStart  = ',num2str(tStart),' tEnd = ', num2str(tEnd),' \newline ',' FFT = ', num2str(f(index+1)*60),' AVG RR  = ',num2str(avgRR));
    
    RRErrs = RRErrs + (abs(dominantFreq - avgRR)/dominantFreq)*100;
%     
%     subplot(3,split,j);
%     hold on;
%     plot(f(2:end)*60,P1(2:end)) ;
%     plot(f(index+1)*60,val,'r^','markerfacecolor',[1 0 0])
%     text(f(index+1)*60,val,txt) 
% 
%     hold off;
%     xlim([0 200]);
%     
%     ylim('auto');
    end
    
%     subplot(3,split,[split+1, 2*split]);
%     plot(time,x(:,4).');

    
    RRErrs = RRErrs / split;
    detsWStamps=x;

    [~,idu] = unique(detsWStamps(:,3));
    uniqueDetVals = detsWStamps(idu,:);
    uniqueDetVals = uniqueDetVals(2:end,:);
    
    detPoints = uniqueDetVals(:,3).';
    if(length(detPoints)>1)
        valAtDetPoints = interp1(uniqueDetVals(:,5).',uniqueDetVals(:,2).',detPoints);
    elseif (length(detPoints)>0)
        valAtDetPoints = uniqueDetVals(1,2);
    else
        valAtDetPoints = [];
    end
    
    path = strcat(thisFolder,'\ManuallyMarked\');
    manualFile = fullfile(path, attrList(i).filename);
    
    manDetects = csvread(manualFile);
    lk = manDetects(:,1).';
  %  pk = manDetects(:,2).';
    pk  = interp1(tResamp,sigResamp,lk);% get values from interp
    matpks = findpeaks(sig);

     
    mandets(i) = length(pk);
    filedets(i) = length(uniqueDetVals(:,2).');
    matdets(i)=length(matpks);
   
  %  Errs2 = Errs2 + 100*abs(length(pk)-length(uniqueDetVals(:,2).'))/length(pk)
   % Errs = Errs + 100*abs(length(pk)-length(tunedDets(:,2).'))/length(pk)
  %  RRErrTot = RRErrTot + RRErrs;
end

countRelErrorPerc = Errs/ctr
countRelErrorPerc2 = Errs2/ctr
RRRelErrorPerc = RRErrTot/ctr;

hold on;

stem(filedets,'LineStyle','--','Marker','x','Color','k','MarkerSize',20);
stem(matdets,'LineStyle','--','Marker','>','Color','m','MarkerSize',10)
stem(mandets,'LineStyle','--','Marker','<','Color','g','MarkerSize',10);

set(gca, 'FontName', 'Times')
xlabel('Test Number') 
ylabel('Detected Breaths') 
legend('Reported', '{\it findpeaks}','Manual');
hold off; 

outputFolder = uigetdir();


fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

savename = 'ad820.pdf';
saveas(gcf,fullfile(outputFolder,savename));
close all;
    

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