clc;clear all; close all;
ib = imread('lena_JPG.jpg'); %%% Reading the image
figure(1); imshow(ib);
[m,n,p]=size(ib);
double tmp;
i1=zeros(m,n);

fp=fopen('testImage_Results_lena.txt','r');
tmp=fscanf(fp,'%d');
tmp=tmp';

for i=1:m
for j=1:n
i1(i,j)=tmp((i-1)*n+j);
end
%fprintf(fp,'\n');
end
fclose(fp);
figure(2);imshow(i1,[])

double tmpB;
iB=zeros(m,n);

fpB=fopen('testImageResults_BLUR.txt','r');

tmpB=fscanf(fpB,'%d');
tmpB=tmpB';

for i=1:m
for j=1:n
iB(i,j)=tmpB((i-1)*n+j);
end
%fprintf(fp,'\n');
end
fclose(fpB);
figure(3);imshow(iB,[])

%}
