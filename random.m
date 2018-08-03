clc
data=[];
tic;
%take system time in milliseconds
for i=1:1:1000
ms=round(toc*1000*60*60*60);
r=mod(ms,2);
if(r==1)
    %disp(r);
    data=[data,r];
else
    %disp(0);
    data=[data,r];
end

end
disp(data);