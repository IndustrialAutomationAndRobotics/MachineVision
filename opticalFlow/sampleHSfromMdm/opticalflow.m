
clear all
clc

index = 0;
ind1 = 0;
angle = 0;
b = 0;

vidIn = VideoReader('C:\Users\Parasite\Desktop\awan.mp4');

endOfFrame = vidIn.NumberOfFrame();

index=index+1;
mov1 = read(vidIn, 10);
mov2 = read(vidIn, 25);

im1 = rgb2gray(mov1);


im2 = rgb2gray(mov2);


[rows, columns] = size(im1);

height = 300;
ratio_b21 = height/rows;

im1=imresize(im1, [height ratio_b21*columns]);
im2=imresize(im2, [height ratio_b21*columns]);

u = zeros(size(im1));
v = zeros(size(im2));
tu = zeros(size(im1));
tv = zeros(size(im2));
[rows, columns] = size(im1);
n = 1;
%---------------------------------------------
% compute derivative

% Check if both images has same size and at gray level.
if(size(im1,1) ~= size(im2,1)) | (size(im1,2) ~= size(im2,2))
    error('input images are not the same size');
end

if(size(im1,3)~=1) | (size(im2,3)~=1)
    error('method only works for gray-level images');
end

%im1 = double(im1);
%im2 = double(im2);

fx = conv2(im1, 0.25*[-1 1;-1 1]) + conv2(im2, 0.25*[-1 1; -1 1]);
fy = conv2(im1, 0.25*[-1 -1;1 1]) + conv2(im2, 0.25*[-1 -1; 1 1]);
ft = conv2(im1, 0.25*ones(2)) + conv2(im2, -0.25*ones(2));

fx = fx(1:size(fx,1)-1, 1:size(fx,2)-1);
fy = fy(1:size(fy,1)-1, 1:size(fy,2)-1);
ft = ft(1:size(ft,1)-1, 1:size(ft,2)-1);

s = 0.001;
% smooth factor
for k=1:n
    for x=2:columns-1
        for y=2: rows-1
            AU(y,x)=(u(y,x-1)+u(y,x+1)+u(y-1,x)+u(y+1,x))/4;
            AV(y,x)=(v(y,x-1)+v(y,x+1)+v(y-1,x)+v(y+1,x))/4;
            A(y,x)=(fx(y,x)*AU(y,x)+fy(y,x)*AV(y,x)+ft(y,x));
            B(y,x)=(1+s*(fx(y,x)*fx(y,x)+fy(y,x)*fy(y,x)));
            tu(y,x)=AU(y,x)-(fx(y,x)*s*(A(y,x)/B(y,x)));
            tv(y,x)=AV(y,x)-(fy(y,x)*s*(A(y,x)/B(y,x)));

        end
    end
    for x=2:columns-1
        
        for y=2:rows-1
            
            u(y,x) = tu(y,x);
            v(y,x) = tv(y,x);
        end
    end
end

h = fspecial('gaussian', [5 5],1);
newu = imfilter(u,h);
newv = imfilter(v,h);

[r,c]=size(newu)

k = 1;

for px=1:r
    for py=1:c
        sm(px,py)=sqrt(newu(px,py)*newu(px,py) + newv(px,py)*newv(px,py));
        if sm(px,py)>0.3
            posisicol(k) = px;
            posisirow(k) = py;
            u2(px,py) = newu(px,py);
            v2(px,py) = newv(px,py);
            u3(k)=newu(px,py);
            v3(k)=newv(px,py);
            k=k+1;
        if ((u2(px,py)*2+v2(px,py)^2)>0)
            ind1=ind1+1;
            angle1(index,ind1)=atan2(v2(px,py),u2(px,py));
            index1=index;
            
            b1=b;
            [a,b] = rose(angle1(index1,:));
            b(1)=b(1)/4;
            
            if(index==1)
                b1=b;
            end
        end
        
        else
            u2(px,py)=0;
            v2(px,py)=0;
           
        end
    end
end

im2 = imresize(im2, [r c]);

sumframe=sum(sum(sm));

figure(1),imshow(im2)

hold on;
quiver(posisirow,posisicol,u3,v3,'r');
hold off;

figure(2), polar(a,b);