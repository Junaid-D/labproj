clc;
clear all;

folder = 'Full_test';
list = dir('*.csv')
ctr = 0;
Errs = 0;

tmp = struct2cell(list);
names = tmp(1,:);
attrList = cellfun(@getAttr,names);
attrList = filterby(attrList,'countable','True');
attrList = filterby(attrList,'ambient','6');
attrList = filterby(attrList,'depth','D');

%attrList = filterby(attrList,'name','J');

for i=1:5
    attrs = attrList(i);
   

    if(list(i).isdir==1 || ~isempty(strfind(list(i).name,'speaker')))
        continue;
    end
    
    ctr=ctr+1;
    x = csvread(list(i).name);


    sig = x(:,2).';
    time = x(:,end).'/1000;

    Ts = time(2)-time(1);
    Fs = 1/Ts;
    L = length(sig);
    Y = fft(sig);
    f = Fs*(0:(L/2))/L;
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    figure();
    subplot(3,1,1);

    plot(f(2:end)*60,P1(2:end)) ;
    subplot(3,1,2);

    plot(time,x(:,4).');

    
    
    detsWStamps=x;

    [~,idu] = unique(detsWStamps(:,3));
    uniqueDetVals = detsWStamps(idu,:);
    uniqueDetVals = uniqueDetVals(2:end,:);
    
    minDist = 0;
    
    if(strcmp(attrs.depth,'S'))
        minDist = 2;
    elseif (strcmp(attrs.depth,'D'))
        minDist = 0;
          
    else
        minDist = 5;
    end
    
    [pk,lk] = findpeaks(sig,'MinPeakDistance',minDist);
    subplot(3,1,3);

    hold on;
    plot(time,sig);
    plot(uniqueDetVals(:,5).'/1000,uniqueDetVals(:,2).','*')
    plot(time(lk),pk,'o')

    hold off;

    Errs= Errs + 100*abs(length(pk)-length(uniqueDetVals(:,2).'))/length(pk)

end
Errs/ctr

function out = getAttr(name)

res.name = '';
res.ambient = '';
res.depth = '';
res.rate = '';
res.mask =  '';
res.interrupted = '';
res.orifice = '';

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