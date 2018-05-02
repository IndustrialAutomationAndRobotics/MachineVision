% Lab Test 3 Machine Vision
% Optical Flow
% Name : Mohamed Hazim Bin Mohamed Gharib
% Id num : 50212116040

clc
clear

%define variable use for optical flow calculation
index = 1;
ind1 = 0;
angle = 0;
b = 0;

% define the path and use count to loop through all frame sequence
path = 'C:\Users\Lab E211\Desktop\sample\adl-01-cam0-rgb-';
endpath = '.png';
count = 89;
fullPath = strcat(path, num2str(count), endpath);

%read first frame and change to grayscale
image1 = imread(fullPath);
image1 = rgb2gray(image1);

for i = 90:116
    
    % define the next path to loop through all frame sequence
    count = i;
    fullPath = strcat(path, num2str(count), endpath);
    
    % read second frame and change to grayscale
    image2 = imread(fullPath);
    image2 = rgb2gray(image2);
    
    %show input image
    figure(1),imshow(image2);
     
    % resize image for faster optical flow calculation
    image1 = imresize(image1, [300 600]);
    image2 = imresize(image2, [300 600]);
     
    % initialize u, v ,tu and tv
    u = zeros(size(image1));
    v = zeros(size(image2));
    tu = zeros(size(image1));
    tu = zeros(size(image2));
    [rows, columns] = size(image1);
    n = 1;
    
    % Check wether both frame are same size and both are gray level
    if(size(image1,1) ~= size(image2,1)) | (size(image1,2) ~= size(image2,2))
        error('input images are not the same size');
    end
    
    if(size(image1,3)~=1) | (size(image2,3)~=1)
        error('method only works for gray-level images');
    end
    
    % change to double for conv2 function calculation
    image1 = double(image1);
    image2 = double(image2);
    
    %% calculation for lx,lu and lt
    % lx = fx
    % lu = fy
    % lt = ft
    fx = conv2(image1, 0.25*[-1 1;-1 1]) + conv2(image2, 0.25*[-1 1; -1 1]);
    fy = conv2(image1, 0.25*[-1 -1;1 1]) + conv2(image2, 0.25*[-1 -1; 1 1]);
    ft = conv2(image1, 0.25*ones(2)) + conv2(image2, -0.25*ones(2));

    fx = fx(1:size(fx,1)-1, 1:size(fx,2)-1);
    fy = fy(1:size(fy,1)-1, 1:size(fy,2)-1);
    ft = ft(1:size(ft,1)-1, 1:size(ft,2)-1);
    
    %% Further calculation using fx,fy and ft to determine u and v
    s = 0.001;
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
    
    [r,c] = size(newu);
    
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
    
    %% Use the value we get to show the optical flow and rosplot
    % from rosplot, we can see that the value go to 90 that is to left
    % the value of u and v are respectively u3 and v3
    % u = u3
    % v = v3
    
    image2 = imresize(image2, [r c]);

    sumframe=sum(sum(sm));

    figure(2),imshow(image2)

    hold on;
    quiver(posisirow,posisicol,u3,v3,'r');
    hold off;

    figure(3), polar(a,b);
    
    %update last image
    image1 = image2;
    
    %% pause at every frame for you to see the answer and the output
    % press spacebar or enter to go to next frame
    pause
    
    
end

