
vidCircle = VideoReader('C:\Users\lab E211\Desktop\circle.mov');
images = read(vidCircle, 1);

figure(1), imshow(images);
images = rgb2gray(images);

[~, threshold] = edge(images, 'sobel');
fudgeFactor = 1;
BWs = edge(images, 'sobel', threshold * fudgeFactor);
%figure(3), imshow(BWs);

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);
%figure, imshow(BWsdil), title('dilated');

BWdfill = imfill(BWsdil, 'holes');
%figure, imshow(BWdfill), title('fill');

BWnobord = imclearborder(BWdfill, 4);
%figure, imshow(BWnobord), title('clear border');

seD = strel('diamond', 1);
BWfinal = imerode(BWnobord,seD);
figure, imshow(BWfinal), title('segmented image');

[row, column] = size(BWfinal);
num_motion = sum(BWfinal(:));
columnWeight = (ones(row,1)*[1:column]).*BWfinal;
%test = sum(columnWeight(:));
cMean = round(sum(columnWeight(:))/num_motion);
