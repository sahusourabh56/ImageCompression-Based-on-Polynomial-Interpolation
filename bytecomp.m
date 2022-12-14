function y = bytecomp(x)

e1= floor(log10(abs(x))); %find out the exponent
E=e1+20; %add exponent with bias
sgn=0; 
if(x<0)
    sgn=1;
end  %set sign bit=1
X=abs(x*10^(-e1+2)); %keep the 3 most significant digits before the decimal point
ro=mod((X*10),10);
if(ro>5)
    X=X+1;
end %round of the number after the decimal point
y1=floor(X/10); %extract the 1st and 2nd MSDs
y2=mod(floor(X),10); %find the 3rd MSD
y1=y1+100*sgn; %process byte 1
y2=10*E+y2; %process byte 2
y(1)=y1;
y(2)=y2; %store the values
end


