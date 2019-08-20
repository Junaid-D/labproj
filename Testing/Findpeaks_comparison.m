clc;
clear all;

folder = 'Full_test';
list = dir('**/*.csv');
ctr = 0;
Errs = 0;
RRErrTot = 0 ;


tmp = struct2cell(list);
names = tmp(1,:);
path = tmp(2,:);
attrList = cellfun(@getAttr,names,path);
attrList = filterby(attrList,'countable','True');
attrList = filterby(attrList,'ambient','30');


for i=1:1
    attrs = attrList(i);
   


    
    ctr=ctr+1;
    x = csvread(fullfile(attrList(i).path,attrList(i).filename));


    sig = x(:,2).';
    time = x(:,end).'/1000;
    
    
    
    [tResamp,sigResamp] = interper(time,sig,40);
    
    tunedDets = gradDetector(tResamp,sigResamp,0.05);
   % figure();
    

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
    minDist = 0;
    
    if(strcmp(attrs.depth,'S'))
        minDist = 4;
    elseif (strcmp(attrs.depth,'D'))
        minDist = 6;
    else
        minDist = 5;
    end
    
    [lk,pk] = peakfinder(sig);
%     subplot(3,split,[2*split+1, 3*split]);

    hold on;
    plot(time,sig);
  %  plot(uniqueDetVals(:,5).'/1000,uniqueDetVals(:,2).','*')
  %  plot(detPoints/1000, valAtDetPoints, '>');
 %   plot(tunedDets(:,1).',tunedDets(:,2).','^')
 %   plot(time(lk),pk,'o')
 
    hold off;

    Errs = Errs + 100*abs(length(pk)-length(tunedDets(:,2).'))/length(pk)
    RRErrTot = RRErrTot + RRErrs;
end
countRelErrorPerc = Errs/ctr

RRRelErrorPerc = RRErrTot/ctr;



function out = getAttr(name,path)

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

function arr = filterby(arr,cat,val)

bools = logical(zeros(1,length(arr)));
for i = 1:length(arr)
    bools(i)=strcmp(arr(i).(cat),val);
end
arr = arr(bools);
end