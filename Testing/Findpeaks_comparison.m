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
attrList = filterby(attrList,'ambient','30');
%attrList = filterby(attrList,'name','J');

for i=1:length(attrList)
    attrs = attrList(i);
   

    if(list(i).isdir==1 || ~isempty(strfind(list(i).name,'speaker')))
        continue;
    end
    
    ctr=ctr+1;
    x = csvread(list(i).name);


    sig = x(:,2).';
    time = x(:,end).';


    detsWStamps=x;

    [~,idu] = unique(detsWStamps(:,3));
    uniqueDetVals = detsWStamps(idu,:);
    uniqueDetVals = uniqueDetVals(2:end,:);


    [pk,lk] = findpeaks(sig);
    figure()
    hold on;
    plot(time,sig);
    plot(uniqueDetVals(:,5).',uniqueDetVals(:,2).','*')
    plot(time(lk),pk,'o')

    hold off;

    Errs= Errs + 100*abs(length(pk)-length(uniqueDetVals))/length(pk)

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