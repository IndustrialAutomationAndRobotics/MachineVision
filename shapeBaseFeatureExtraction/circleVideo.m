vidIn = VideoReader('C:\Users\lab E211\Desktop\rectangle.mov');
 eee=[];
 hhh=[];
for ii = 1:5:vidIn.NumberOfFrames;
    pic = read(vidIn, ii);
    images = rgb2gray(pic);

    % Segmentation part
    % Use the threshold to get better results for binary image
    [~, threshold] = edge(images, 'sobel');
    fudgeFactor = 1;
    BWs = edge(images, 'sobel', threshold * fudgeFactor);
    %figure(3), imshow(BWs);

    % Morphological technique
    % Dilate it so that the part we don't want will connected to the side.
    % Then we can eliminate it with imclearborder.
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    BWsdil = imdilate(BWs, [se90 se0]);
    %figure, imshow(BWsdil), title('dilated');

    % Fill the hole to get the perfect circle
    BWdfill = imfill(BWsdil, 'holes');
    %figure, imshow(BWdfill), title('fill');

    % Clear the connected object to the border of the frame
    BWnobord = imclearborder(BWdfill, 4);
    %figure, imshow(BWnobord), title('clear border');

    % We erode it back to get back the actual size and remove some noise
    seD = strel('diamond', 1);
    BWfinal = imerode(BWnobord,seD);
    %imshow(BWfinal), title('segmented image');
   
    [row, column] = size(BWfinal);
    n1=10;
   

% num_motion is the total sum of the value of pixel
% in the image. Since BWfinal is in binary. The sum
% is the total of all the white pixel.
num_motion = sum(BWfinal(:));

% ones(row,1) : return a 1 dimensional array consist of ones(1).
%               The size of the array is 320 x 1 which is the size 
%               of the row of our image
% [1:column]  : return a 1 dimensional array consist of incremental value
%               from 1 till 568, which is the column of our image

% EXAMPLE -------
% Imagine we have a 5 x 5 binary image which has 2 x 2 square in it.
% The matrix will look like this
%       0 0 0 0 0
%       0 0 1 1 0
%       0 0 1 1 0
%       0 0 0 0 0
%       0 0 0 0 0
%
% the first equation(ones(row,1)) will return 1 5 times
% the second equation([1:column]) will return 1 till 5.
% So, when we multiply both we get
%       1 2 3 4 5
%       1 2 3 4 5
%       1 2 3 4 5
%       1 2 3 4 5
%       1 2 3 4 5
% Then when we multiply both matrix we get
%       0 0 0 0 0
%       0 0 3 4 0
%       0 0 3 4 0
%       0 0 0 0 0
%       0 0 0 0 0
% The same happens below, but our image is 320 x 568
columnWeight = (ones(row,1)*[1:column]).*BWfinal;

% cMean is the division of the total columnWeight with num_motion
cMean = round(sum(columnWeight(:))/num_motion);

% a1 is the sum of the columnWeight squared which is a big number
% a2 is the result of a1 divide by num_motion.
a1 = sum(columnWeight(:).^2);
a2 = (sum(columnWeight(:))^2)/num_motion;
cStd = round(sqrt((a1-a2)/(num_motion-1)));

% in rowWeight, same happen as columnWeight but for rows
% EXAMPLE -------
% Imagine we have a 5 x 5 binary image which has 2 x 2 square in it.
% The matrix will look like this
%       0 0 0 0 0
%       0 0 1 1 0
%       0 0 1 1 0
%       0 0 0 0 0
%       0 0 0 0 0
%
% the first equation(ones(1,column)) will return 1 5 times
% the second equation([1:row]) will return 1 till 5.
% So, when we multiply both we get
%       1 1 1 1 1
%       2 2 2 2 2
%       3 3 3 3 3
%       4 4 4 4 4
%       5 5 5 5 5
% Then when we multiply both matrix we get
%       0 0 0 0 0
%       0 0 2 2 0
%       0 0 3 3 0
%       0 0 0 0 0
%       0 0 0 0 0
% The same happens below, but our image is 320 x 568
rowWeight = ([1:row]'*ones(1,column)).*BWfinal;
rMean = round(sum(rowWeight(:))/num_motion);

a1 = sum(rowWeight(:).^2);
a2 = (sum(rowWeight(:))^2)/num_motion;
rStd = round(sqrt((a1-a2)/(num_motion-1)));

std_weight = 2.2;
rStd = rStd*std_weight;
cStd = cStd*std_weight;
test = cMean + min(cStd, ceil(column/2));
ColumnStart = max(1, cMean - min(cStd, ceil(column/2)));
ColumnEnd = min(column, cMean + min(cStd, ceil(column/2)));
RowStart = max(1, rMean - min(rStd, ceil(row/2)));
RowEnd = min(row, rMean + min(rStd, ceil(row/2)));

% Draw the lines of the row and column
%line([ColumnStart, ColumnEnd], [RowStart, RowStart], 'Color','blue','Linewidth',2);
%line([ColumnStart, ColumnEnd], [RowEnd, RowEnd], 'Color','blue','Linewidth',2);
%line([ColumnStart, ColumnStart], [RowStart, RowEnd], 'Color','blue','Linewidth',2);
%line([ColumnEnd, ColumnEnd], [RowStart, RowEnd], 'Color','blue','Linewidth',2);
%drawnow;

% crop image
Y=imcrop(BWfinal,[ColumnStart, RowStart,ColumnEnd-(ColumnStart),RowEnd-(RowStart)]);
[row,column] = size(Y);
Y = double(Y);

%imshow(Y);
    
stats = regionprops(Y, 'basic');
Y1=stats(1).Centroid;
Y1=round(Y1);
xc = Y1(1); yc=Y1(2);
test = Y(:,:);

% loop dari centroid horizontally ke max column.
% nilai h1 akan simpan position pixel bila nilai pixel = 1
h1 = 0; bil = 1;
for i = xc:column
    if Y(yc,i)==1
        h1=i;
    else
        if h1<=0
            h1=1;
        end
    end
end
s0 = [h1 yc];

% loop dari min row vertically hingga ke centroid
% nilai v1 akan increment bila nilai pixel = 0
v1 = 0;
for i = 1:yc
    if Y(i,xc)==0
        v1=i+1;
    else
        if v1 <= 0
            v1 = 1;
        end
    end
    disp(v1);
end
s9=[xc v1];

% loop dari min column horizontaly hingga ke centroid
% nilai h2 akan increment bila nilai pixel = 0
h2 = 0;
for i = 1:xc
    if Y(yc, i)==0
        h2=i+1;
    else
        if h2<=0
            h2=1;
        end
    end
end
s18=[h2 yc];

% loop dari centroid vertically hingga ke max row
% nilai v2 akan simpan position pixel bila nilai pixel = 1
v2 = 0;
for i=yc:row
    if Y(i,xc)==1
        v2=i;
    else
        if v2<=0
            v2=1;
        end
    end
end
s27=[xc,v2];

% uncomment kalo nak tengok result dari coding atas tu
%imshow(Y);
%hold on;
%plot(h1,yc,'r*','LineWidth',2,'MarkerSize', 10);
%plot(xc,v1,'r*','LineWidth',2,'MarkerSize', 10);
%plot(h2,yc,'r*','LineWidth',2,'MarkerSize', 10);
%plot(xc+100,yc,'r*','LineWidth',2,'MarkerSize', 10);

A=0;B=0;C=0;D=0;


% This will loop from 10 till 80 by 10.
% get max value at each 10 degree point 10 - 80 degree
for n=n1:n1:90-n1
    for i=1:column*3
   
        belahan = round(i*(cos((n/180)*pi)));
        titikbelahan=[xc+belahan,yc];
        tegak=round(sqrt((i^2)-(belahan^2)));
        titiksendeng=[xc+belahan,yc-tegak];
        TEGAK = yc-tegak;
        LINTANG = xc + belahan;
        if TEGAK >= row
            TEGAK=TEGAK; A=A+1;
            break
        elseif LINTANG>=column
            LINTANG=LINTANG; B=B+1;
            break
        elseif LINTANG <= 0
            LINTANG=LINTANG; C=C+1;
            break
        elseif TEGAK <= 0
            TEGAK=TEGAK; D=D+1;
            break
        elseif Y(TEGAK,LINTANG)==1
        else
            break
            
        end
    end
    s1 = [LINTANG-1 TEGAK];
    q1(bil,1)=s1(1,1);
    q1(bil,2)=s1(1,2);
    bil=1+bil;
end

% loop di atas diulang untuk angle yang lainnya
% max value untuk angle 100 - 170
bil=1;
for n=90+n1:n1:180-n1
    for i=1:column*2
        belahan=round(i*(cos((n/180)*pi)));
        titikbelahan=[xc+belahan,yc];
        tegak=round(sqrt((i^2)-(belahan^2)));
        titiksendeng=[xc+belahan,yc-tegak];
        TEGAK = yc - tegak;
        LINTANG = xc + belahan;
        if TEGAK >= row
            TEGAK=TEGAK;
            break
        elseif LINTANG>=column
            LINTANG=LINTANG;
            break
        elseif LINTANG <= 0
            LINTANG=LINTANG;
            break
        elseif TEGAK <=0
            TEGAK=TEGAK;
            break
        elseif Y(TEGAK, LINTANG)==1
        else
            break
        end
    end
    s2=[LINTANG+1 TEGAK];
    q2(bil,1)=s2(1,1);
    q2(bil,2)=s2(1,2);
    bil=1+bil;
end

%ulang loop untuk angle 190 - 260
%method lebih kurang sama macam 10 - 80
bil=1;
for n=180-n1:-n1:90+n1
    for i=1:column*3
        belahan=round(i*(cos((n/180)*pi)));
        titikbelahan=[xc+belahan,yc];
        tegak=round(sqrt((i^2)-(belahan^2)));
        titiksendeng=[xc+belahan,yc+tegak];
        TEGAK = yc+tegak;
        LINTANG = xc + belahan;
        if TEGAK >= row
            TEGAK=TEGAK;
            break
        elseif LINTANG>=column
            LINTANG=LINTANG;
            break
        elseif LINTANG <= 0
            LINTANG=LINTANG;
            break
        elseif TEGAK <=0
            TEGAK=TEGAK;
            break
        elseif Y(TEGAK,LINTANG)==1
        else
            break
        end
    end
    s3=[LINTANG+1,TEGAK];
    q3(bil,1)=s3(1,1);
    q3(bil,2)=s3(1,2);
    bil=1+bil;
end

% ulang loop untuk 10 angle akhir
bil=1;
for n=90-n1:-n1:n1
    for i=1:column*3
        belahan=round(i*(cos((n/180)*pi)));
        titikbelahan=[xc+belahan,yc];
        tegak=round(sqrt((i^2)-(belahan^2)));
        titiksendeng=[xc+belahan,yc+tegak];
        TEGAK = yc+tegak;
        LINTANG = xc + belahan;
        if TEGAK >= row
            TEGAK=TEGAK;
            break
        elseif LINTANG>=column
            LINTANG=LINTANG;
            break
        elseif LINTANG <= 0
            LINTANG=LINTANG;
            break
        elseif TEGAK <=0
            TEGAK=TEGAK;
            break
        elseif Y(TEGAK,LINTANG)==1
        else
            break

        end
    end
    s4=[LINTANG-1 TEGAK];
    q4(bil,1)=s4(1,1);
    q4(bil,2)=s4(1,2);
    bil=1+bil;
end

kkk=((90-n1)/n1);

% calculate the distance form centroid for each
% point starting from horizontal right counter
% clockwise

d0=round(sqrt((s0(1)-xc)^2+(s0(2)-yc)^2));
for n=1:kkk
    dq1(n)=round(sqrt((q1(n,1)-xc)^2+(q1(n,2)-yc)^2));
end
d9=round(sqrt((s9(1)-xc)^2+(s9(2)-yc)^2));
for n=1:kkk
    dq2(n)=round(sqrt((q2(n,1)-xc)^2+(q2(n,2)-yc)^2));
end
d18=round(sqrt((s18(1)-xc)^2+(s18(2)-yc)^2));
for n=1:kkk
    dq3(n)=round(sqrt((q3(n,1)-xc)^2+(q3(n,2)-yc)^2));
end
d27=round(sqrt((s27(1)-xc)^2+(s27(2)-yc)^2));
for n=1:kkk
    dq4(n)=round(sqrt((q4(n,1)-xc)^2+(q4(n,2)-yc)^2));
end

d0;a=dq1;d9;b=dq2;d18;c=dq3;d27;d=dq4;
strNumOfString = num2str(ii);
strFigure = 'figure '
numOfFigure = sprintf('%s_%s',strFigure,strNumOfString);
figure(1),imshow(Y),title(numOfFigure)
hold
plot(Y1(1),Y1(2),'r+');plot(s0(1),s0(2),'r+');plot(s9(1),s9(2),'r+');
plot(s18(1),s18(2),'r+');plot(s27(1),s27(2),'r+');
axis equal
for n=1:kkk
    xx=[Y1(1),q1(n,1)];yy=[Y1(2),q1(n,2)];plot(xx,yy,'b-');
    xx=[Y1(1),q2(n,1)];yy=[Y1(2),q2(n,2)];plot(xx,yy,'b-');
    xx=[Y1(1),q3(n,1)];yy=[Y1(2),q3(n,2)];plot(xx,yy,'b-');
    xx=[Y1(1),q4(n,1)];yy=[Y1(2),q4(n,2)];plot(xx,yy,'b-');
end
xx=[Y1(1),s0(1,1)];yy=[Y1(2),s0(1,2)];plot(xx,yy,'b-');
xx=[Y1(1),s9(1,1)];yy=[Y1(2),s9(1,2)];plot(xx,yy,'b-');
xx=[Y1(1),s18(1,1)];yy=[Y1(2),s18(1,2)];plot(xx,yy,'b-');
xx=[Y1(1),s27(1,1)];yy=[Y1(2),s27(1,2)];plot(xx,yy,'b-');

% f is the centroid
f=[xc, yc]
% g is the point at every 10 degree
g = [s0 ; q1(1,:) ; q1(2,:) ; q1(3,:) ; q1(4,:) ; q1(5,:) ; q1(6,:) ; q1(7,:) ; q1(8,:) ;
    s9 ; q2(1,:) ; q2(2,:) ; q2(3,:) ; q2(4,:) ; q2(5,:) ; q2(6,:) ; q2(7,:) ; q2(8,:) ;
    s18 ; q3(1,:) ; q3(2,:) ; q3(3,:) ; q3(4,:) ; q3(5,:) ; q3(6,:) ; q3(7,:) ; q3(8,:) ;
    s27 ;  q4(1,:) ; q4(2,:) ; q4(3,:) ; q4(4,:) ; q4(5,:) ; q4(6,:) ; q4(7,:) ; q4(8,:) ]
% eee is the distance of all 36 point with centroid
e=[d0 a d9 b d18 c d27 d];ee=e;eee=[eee;ee];

for i=1:36
    h(i,1) = ii;
    h(i,2) = f(1);
    h(i,3) = f(2);
    h(i,4) = g(i,1);
    h(i,5) = g(i,2);
    h(i,6) = e(1,i);
end

hh=h;hhh=[hhh;hh];

end

filename = 'C:\Users\lab E211\Desktop\rectangle.xlsx';
xlswrite(filename,hhh,1,'A2');