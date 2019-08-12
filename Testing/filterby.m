function arr = filterby(arr,cat,val,IncOrExc)

bools = logical(zeros(1,length(arr)));
for i = 1:length(arr)
    bools(i)=strcmp(arr(i).(cat),val);
end

if (~IncOrExc)
bools  = ~bools;
end

arr = arr(bools);
end