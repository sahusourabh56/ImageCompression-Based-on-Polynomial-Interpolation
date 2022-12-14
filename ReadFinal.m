%clear all;


file=fopen('image.bin','r'); %name of file to be read for decompression

nr1=(fscanf(file,'%c',1));  %first byte storing number of rows
nr2=(fscanf(file,'%c',1));  %second byte storing number of rows 
nr=256*nr1+nr2; %calculating the number of rows from the two bytes
nc1=(fscanf(file,'%c',1)); 
nc2=(fscanf(file,'%c',1));
nc=256*nc1+nc2; %calculating number of cloumns from the two bytes
segments=double(fscanf(file,'%c',1)); %retreiving number of row segments
d=double(fscanf(file,'%c',1)); %retreiving order of the polynomial

x=1:nc;
fragments=n/segments;



for k=1:fragments
    x1(k)=k;
end

%intiating matrices to store the decompressed polnomial and image pixel
%matrix for each image channel

%matrix to store image pixel intensity
z1=uint8(zeros(nr,nc));
z2=z1;
z3=z1;
%matrix to store polynomial coefficients decompressed from image
Polyr=zeros(nr,segments,d+1);
Polyg=Polyr;
Polyb=Polyr;
%matrix to store retreived compressed coefficients
Coefr=zeros(nr,segments,d+1,2);
Coefg=zeros(nr,segments,d+1,2);
Coefb=zeros(nr,segments,d+1,2);

for i=1:nr
    for k=1:segments
        for j=1:d+1
            
            %retreiving the stored compressed coefficients for each channel one by one
            Coefr(i,k,j,1)=(fscanf(file,'%c',1));
            Coefr(i,k,j,2)=(fscanf(file,'%c',1));
            Coefg(i,k,j,1)=(fscanf(file,'%c',1));
            Coefg(i,k,j,2)=(fscanf(file,'%c',1));
            Coefb(i,k,j,1)=(fscanf(file,'%c',1));
            Coefb(i,k,j,2)=(fscanf(file,'%c',1)); 
            
            %decompressing the compressed coefficients for each channel
            Polyr(i,k,j)=byteexp(Coefr(i,k,j,:));
            Polyg(i,k,j)=byteexp(Coefg(i,k,j,:));
            Polyb(i,k,j)=byteexp(Coefb(i,k,j,:));
            
        end
            
    end
end

fclose(file);



figure(1)
for i=1:nr
    a3=cat(3,z1,z2,z3); %showing the decomprssed image at the start of each row
    imshow(a3);
    for k=0:segments-1 
        p1(1,:)=Polyr(i,k+1,:); %storing the decompressing polynomial coefficinets in a vector for polynomial evaluation
        p2(1,:)=Polyg(i,k+1,:);
        p3(1,:)=Polyb(i,k+1,:);
        for j=1:fragments
            z1(i,k*fragments+j)=uint8(polyval(p1,j)); %regenerating red channel segment
            z2(i,k*fragments+j)=uint8(polyval(p2,j)); %regenerating green channel segment
            z3(i,k*fragments+j)=uint8(polyval(p3,j)); %regenerating blue channel segment
        end
    end
end


