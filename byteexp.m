function y=byteexp(x)

sgn=(-1)^floor(x(1)/100);%extract the sign bit
ms=mod(x(1),100); %extract the 1st and 2nd MSB
ls=mod(x(2),10); %extract the 3rd MSB
E=floor(x(2)/10)-22; %extract the exponent and subtract the bias+2
y=double(sgn*(ms*10+ls)*10^E);
end

