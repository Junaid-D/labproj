clc;
clear all;

folder = 'Full_test';
cd (folder);
list = dir('*.csv');
subfolder = pwd();
cd('..');
thisFolder = pwd();
ctr = 0;
Errs = 0;
Errs2 = 0;
RRErrTot = 0 ;


tmp = struct2cell(list);
names = tmp(1,:);
attrList = cellfun(@getAttr,names);
attrList = filterby(attrList,'countable','True',1);
attrList = filterby(attrList,'ambient','23',1);
attrList = filterby(attrList,'orifice','M',1);
attrList = filterby(attrList,'name','M',1);
attrList = filterby(attrList,'rate','F',1);



for i=1:length(attrList)
    attrs = attrList(i);
   


    
    ctr=ctr+1;
    fullpth = fullfile(subfolder, attrList(i).filename);
    x = csvread(fullpth);

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
