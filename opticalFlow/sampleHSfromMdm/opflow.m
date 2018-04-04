clear all
clc

index = 0;
ind1 = 0;
angle = 0;
b = 0;
a = 0;
eee=[];n1=10;
vidIn = VideoReader('C:\Users\lab E211\Desktop\starTexture.mp4');

endOfFrame = vidIn.NumberOfFrame();

for bil=20:30
    
    index=index+1;
    
    mov1 = read(vidIn, bil);
    mov2 = read(vidIn, bil+1);
    
    
im1 =rgb2gray(mov1);
    im1=imresize(im1,[240 320]);
    
    im2 =rgb2gray(mov2);
    im2=imresize(im2,[240 320]);
%save file movie to offline image
%     filname1=strcat('VN1_',int2str(bil));
%     filname1=strcat(filname1,'.jpg');
%     imwrite(im1,filname1);
[u1,v1]=OFV1(im1,im2,0.001);

   %[u1, v1] = optic_flow_sand_thesis(im1,im2,8);
    %menggunakan gaussian filter

    h=fspecial('gaussian',[5 5],1);
    newu1=imfilter(u1,h);
    newv1=imfilter(v1,h);

    %menggunakan medfilter filter
    %newu1=Reduce(Reduce(medfilt2(newu,[5 5])));
    %newv1=Reduce(Reduce(medfilt2(newv,[5 5])));

    % optical flow without segmentation
    [r,c]=size(newu1)
    k=1;

    for px=1:r
        for py=1:c
            sm(px,py)=sqrt(newu1(px,py)*newu1(px,py) +newv1(px,py)*newv1(px,py));
            if sm(px,py)>0.1   %%%%%magnitude
                posisicol(k)=px;
                posisirow(k)=py;
                u2(px,py)=newu1(px,py);
                v2(px,py)=newv1(px,py);
                u3(k)=newu1(px,py);
                v3(k)=newv1(px,py);
                k=k+1;
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
               if ((u2(px,py)*2+v2(px,py)^2)>0)
                    ind1=ind1+1;
                    angle1(index,ind1)=atan2(v2(px,py),u2(px,py)); %%%%%angle
                    index1=index;
                    
                    b1=b;
                    
                    [a,b] = rose(angle1(index1,:));
                    b(1)=b(1)/4;

                    if (index==1)
                        b1= b;
                    end
               end
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
               
               
            else
                
                u2(px,py)=0;
                v2(px,py)=0;
%                 posisicol(k)=px;
%                 posisirow(k)=py;

            end

        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    name='BROXof_';
    filename=sprintf('%s%d.mat',name,bil);
    save(filename, 'u2', 'v2');

    im2=imresize(im2,[r c]);
    
    %%%%%%%%
%     if sum(sum(sm>0.2))
        
    sumframe=sum(sum(sm));
        
        
    figure(1),
    imshow(im2)
     
    hold on;
%     quiver(u2, v2,'r');
     quiver(posisirow,posisicol,u3, v3,'r');
    hold off;
    
    figure(2),
    polar(a,b);
    
    k=0;
    for i = 1:80
        if mod(i,4)==2
            k=k+1;
            bbaru(k)=b(i);
        else
            
        end
    end
    
    data=[sumframe bbaru bil];
    eee=[eee;data];

    
    
end



