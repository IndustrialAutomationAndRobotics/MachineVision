
% Read the input vedio and get only the first frame
vidInput = VideoReader('C:\Users\lab E211\Desktop\circle.mov');
images = read(vidInput, 1);

% Show it and change it to grayscale for segmentation method
%figure(1), imshow(images);
images = rgb2gray(images);

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
figure, imshow(BWfinal), title('segmented image');

% Shape Based Feature Extraction part
[row, column] = size(BWfinal);

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
line([ColumnStart, ColumnEnd], [RowStart, RowStart], 'Color','blue','Linewidth',2);
line([ColumnStart, ColumnEnd], [RowEnd, RowEnd], 'Color','blue','Linewidth',2);
line([ColumnStart, ColumnStart], [RowStart, RowEnd], 'Color','blue','Linewidth',2);
line([ColumnEnd, ColumnEnd], [RowStart, RowEnd], 'Color','blue','Linewidth',2);
%drawnow;

% crop image
Y=imcrop(BWfinal,[ColumnStart, RowStart,ColumnEnd-(ColumnStart),RowEnd-(RowStart)]);
[row,column] = size(Y);
Y = double(Y);

%figure, imshow(Y);

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
%plot(xc,v2,'r*','LineWidth',2,'MarkerSize', 10);

A=0;B=0;C=0;D=0;