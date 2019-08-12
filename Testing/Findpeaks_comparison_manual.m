clc;
clear all;

folder = 'Full_test';
list = dir('*.csv');
thisFolder = list(1).folder;

ctr = 0;
Errs = 0;
Errs2 = 0;
RRErrTot = 0 ;


tmp = struct2cell(list);
names = tmp(1,:);
attrList = cellfun(@getAttr,names);
attrList = filterby(attrList,'countable','True',1);
attrList = filterby(attrList,'ambient','35',0);


for i=1:length(attrList)
    attrs = attrList(i);
   


    
    ctr=ctr+1;
    x = csvread(attrList(i).filename);


    sig = x(:,2).';
    time = x(:,end).'/1000;
    
    
    
    [tResamp,sigResamp] = interper(time,sig,40);
    
    tunedDets = gradDetector(tResamp,sigResamp,0.05);
%      figure();
    

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

%     subplot(3,split,[2*split+1, 3*split]);
% 
%     hold on;
%    plot(time,sig);
%    plot(uniqueDetVals(:,5).'/1000,uniqueDetVals(:,2).','*')
%    plot(detPoints/1000, valAtDetPoints, '>');
%    plot(tunedDets(:,1).',tunedDets(:,2).','^')
%    plot(lk,pk,'o')
%  
%     hold off;
    Errs2 = Errs2 + 100*abs(length(pk)-length(uniqueDetVals(:,2).'))/length(pk)
    Errs = Errs + 100*abs(length(pk)-length(tunedDets(:,2).'))/length(pk)
    RRErrTot = RRErrTot + RRErrs;
end
countRelErrorPerc = Errs/ctr
countRelErrorPerc2 = Errs2/ctr
RRRelErrorPerc = RRErrTot/ctr;



function out = getAttr(name)

res.name = '';
res.ambient = '';
res.depth = '';
res.rate = '';
res.mask =  '';
res.interrupted = '';
res.orifice = '';
res.filename = name;

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