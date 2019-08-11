clc;
clear all;

folder = 'Full_test';
list = dir('*.csv');
ctr = 0;
Errs = 0;
RRErrTot = 0 ;


tmp = struct2cell(list);
names = tmp(1,:);
attrList = cellfun(@getAttr,names);
attrList = filterby(attrList,'countable','True');
%attrList = filterby(attrList,'name','J');
attrList = filterby(attrList,'ambient','29');


for i=1 : length(attrList)
    attrs = attrList(i);
    
    ctr=ctr+1;
    x = csvread(attrList(i).filename);


    sig = x(:,2).';
    time = x(:,end).'/1000;
      
    [tResamp,sigResamp] = interper(time,sig,40);
    
    tunedDets = gradDetector(tResamp,sigResamp,0.05);
    figure();
    
    split = 5;
    
    sigReshaped = reshape(sigResamp,[],split);
    tReshaped = reshape(tResamp,[],split);
    
    Ts = tResamp(2)-tResamp(1);
    Fs = 1/Ts;
    RRErrs = 0;
    
    plot(time,sig);
   
    [xpts,ypts] = getpts
    close;
    folder = uigetdir();
    
    f = fullfile(folder,attrList(i).filename);
    csvwrite(f,[xpts,ypts]);
    



end



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

function arr = filterby(arr,cat,val)

bools = logical(zeros(1,length(arr)));
for i = 1:length(arr)
    bools(i)=strcmp(arr(i).(cat),val);
end
arr = arr(bools);
end