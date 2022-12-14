%clear all;

img= imread('lena_color_512.jpg');% Image to be compressed

r = img(:,:,1); % Red channel

g = img(:,:,2); % Green channel

b = img(:,:,3); % Blue channel

z=zeros(size(img,1),size(img,2)); 

nr=size(img,1); %number of rows in the image

nc=size(img,2); %number of columns in the image 

x1=[];
A1=cat(3,z,g,b); 

x=1:nc;
segments=32; %number of segments in the image row
fragments=nc/segments; %number of resultants in each segments of image row

d=4; %degree of the polynomial

x1=1:fragments;

% declaring empty matrices to store the interpolated and compressed image rows

y1=[];
y2=y1;
y3=y1;

Z1=uint8(zeros(nr,nc));
Z2=Z1;
Z3=Z1;

z1=Z1;
z2=z1;
z3=z1; 

%declaring empty matrices to store the polynomial coefficients in each
%regression cycle
Polyr=zeros(nr,segments,d+1);
Polyg=Polyr;
Polyb=Polyr;

%declaring empty matrices to store the polynomial coefficients in each
%regression cycle evaluated after compressing them in 2 bytes
p1=zeros(1,d+1);
p2=zeros(1,d+1);
p3=zeros(1,d+1);

%declaring 4 D matrix to store the generated coefficient in 2 bytes

Coefr=zeros(nr,segments,d+1,2);
Coefg=zeros(nr,segments,d+1,2);
Coefb=zeros(nr,segments,d+1,2); 

%empty vectors to discuss the largest and smallest generated polynomial
%coefficients

Pmax=zeros(1,d+1);
Pmin=zeros(1,d+1);
Pmx=zeros(1,d+1);

Pmn=500*ones(1,d+1);
Pcat=zeros(3,d+1);
Cmp=zeros(d+1,3);


%opened the relavent file to store data

file=fopen('image.bin','w');

fprintf(file,'%c',uint8(nr/256));
fprintf(file,'%c',uint8(mod(nr,256)));%storing number of rows in 2 bytes

fprintf(file,'%c',uint8(nc/256));
fprintf(file,'%c',uint8(mod(nc,256)));%storing number of columns in 2 bytes

fprintf(file,'%c',uint8(segments)); %storing number of image segments used
fprintf(file,'%c',uint8(d)); %storing order of the polynomial being interpolated


figure(1)

for i=1:nr
    A3=cat(3,Z1,Z2,Z3); %displaying regression generated image at the start of each loop
    imshow(A3);
    
    for k=0:segments-1  %row image segmentation
        
        for j=1:fragments  %fragment operation inside segment to read intensity distribution in three channels in each channel for a segment
            y1(j)=r(i,k*fragments+j);
            y2(j)=g(i,k*fragments+j);
            y3(j)=b(i,k*fragments+j);
        end
            
            %finding polynomial coefficients for releant degree for the given row segment 
            P1=polyfit(x1',y1',d);  
            P2=polyfit(x1',y2',d);
            P3=polyfit(x1',y3',d);
            
            %storing each generated coefficient for each row fragment
            %sequentially for all channels in the file after compresseing
            %the
        for l=1:d+1
            Coefr(i,k+1,l,:)=bytecomp(P1(l));   %compressing coefficient for red channel
            fprintf(file,'%c',uint8(Coefr(i,k+1,l,1)));
            fprintf(file,'%c',uint8(Coefr(i,k+1,l,2))); %storing the compressed coefficient for red channel sequentially in the file
            Coefg(i,k+1,l,:)=bytecomp(P2(l));   %compressing coefficient for blue channel
            fprintf(file,'%c',uint8(Coefg(i,k+1,l,1))); 
            fprintf(file,'%c',uint8(Coefg(i,k+1,l,2))); %storing the compressed coefficient for blue channel sequentially in the file
            Coefb(i,k+1,l,:)=bytecomp(P3(l));   %compressing coefficient for red channel
            fprintf(file,'%c',uint8(Coefb(i,k+1,l,1)));
            fprintf(file,'%c',uint8(Coefb(i,k+1,l,2))); %storing the compressed coefficient for green channel sequentially in the file
        end
              
            %storing all generated coefficients for row segment in a 2D
            %matrix
            Pcat(1,:)=P1;
            Pcat(2,:)=P2;
            Pcat(3,:)=P3;
            
            Pmax=max(abs(Pcat)); %finding the absolute maximnum of the generated coefficients for the row segment
            Pmin=min(abs(Pcat)); %finding the absolute minimum of the generated coefficients for the row segment
            Pmx=max(Pmax,Pmx);  %updating the absolute maximum coefficient with the relative maximum of current maximum coefficient and row segment maximum coefficient
            Pmn=min(Pmin,Pmn);  %updating the absolute minimum coefficient with the relative minimum of current minimum coefficient and row segment minimum coefficient
            
            %generated intensity for all points from the interpolated polynomial coefficients for red green and blue channels
        for j=1:fragments
            Z1(i,k*fragments+j)=uint8(polyval(P1,j));  
            Z2(i,k*fragments+j)=uint8(polyval(P2,j));
            Z3(i,k*fragments+j)=uint8(polyval(P3,j));
        end
        
    end
end

SNRr=mean(mean((r./(r-Z1)).^2));  %SNR of red channel wrt original matrix
SNRg=mean(mean((g./(g-Z2)).^2));  %SNR of green channel wrt original matrix
SNRb=mean(mean((b./(b-Z3)).^2));  %SNR of blue channel wrt original matrix
SNR=(SNRr+SNRg+SNRb)/3; %avergae SNR accross all channels
SNRdb=10*log10(SNR);

fclose(file); %close the file 
Cmp(:,1)=P1;
Cmp(:,2:3)=Coefr(nr,segments,:,:);

%regenerating the image from the compressed coeffcient matrices 

for i=1:nr
    
    for k=1:segments
            %regenating the coefficients from the compressed coefficient
            %data
        for j=1:d+1
            Polyr(i,k,j)=byteexp(Coefr(i,k,j,:)); %decompressing red channel coefficient
            Polyg(i,k,j)=byteexp(Coefg(i,k,j,:)); %decompressing gren channel coefficient
            Polyb(i,k,j)=byteexp(Coefb(i,k,j,:)); %decompressing blue channel coefficient
        end
        
    end
    
end

%checking relative intensity distributions for original and interpolated
%image for one row in the image matrix

figure(2)
plot(x,r(1,:));
hold on
plot(x,Z1(1,:));
title('Intensity Distribution for a row for red Channel');
xlabel('Column Pixel Number') ;
ylabel('Intensity'); 
legend({'Original Intensity','Fitted Polynomial Curve'},'Location','southwest')
pcat=zeros(3,d+1);
imwrite(A3,'PolySegment.jpg');


%compressed image regeneration
figure(3)
for i=1:nr
    
    a3=cat(3,z1,z2,z3);
    imshow(a3); %displaying the interpolated image at the start of each row operation
    
    %for given row segment coefficients of interpolation extracter for red green and blue channels
    for k=0:segments-1 
        p1(1,:)=Polyr(i,k+1,:); 
        p2(1,:)=Polyg(i,k+1,:);
        p3(1,:)=Polyb(i,k+1,:);
        
        %reevaluating the intensity distribution from the decompressed
        %coefficients
        for j=1:fragments
            z1(i,k*fragments+j)=uint8(polyval(p1,j)); 
            z2(i,k*fragments+j)=uint8(polyval(p2,j));
            z3(i,k*fragments+j)=uint8(polyval(p3,j));
        end
        
    end
    
end

SNRrc=mean(mean((r./(r-z1)).^2)); %SNR of red channel wrt original matrix
SNRgc=mean(mean((g./(g-z2)).^2)); %SNR of green channel wrt original matrix
SNRbc=mean(mean((b./(b-z3)).^2)); %SNR of blue channel wrt original matrix
SNRc=(SNRrc+SNRgc+SNRbc)/3; %average SNR of the decompressed image
SNRcdb=10*log10(SNRc); %SNR in db

figure(4)
plot(x,r(1,:));
hold on
plot(x,z1(1,:));