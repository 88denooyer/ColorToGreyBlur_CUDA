clc;close all
clear all;

I=imread('lena_JPG.jpg');
%I=imread('RGB_abstruct.jpg'); %use for the RGB_abstruct.jpg Image
figure(1); imshow(I)
[m,n,p]=size(I);

%fp=fopen('test_image_RGB.txt','w'); %use for the RGB_abstruct.jpg Image
fp=fopen('test_image_lena.txt','w');

    for j=1:m
        for k=1:n
            for l=1:p
                fprintf(fp,'%4d',I(j,k,l));
            end
        end
        fprintf(fp,'\n');
    end
    fclose(fp);
    
    