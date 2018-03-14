clear all

% Read the video file
vidIn = VideoReader('C:\Users\lab E211\Desktop\hands.mp4');

% The array use to store the feature
hhh = []

% loop through the frame needed
for ii = 1185:1260;
    
    % read the frame
    pic = read(vidIn, ii);
    %imshow(pic);
    
    % Change it to grayscale
    images = rgb2gray(pic);

    % Segmentation part
    % Using morphological technique
    % Use the threshold to get better results for binary image
    [~, threshold] = edge(images, 'sobel');
    fudgeFactor = .9;
    BWs = edge(images, 'sobel', threshold * fudgeFactor);
    %imshow(BWs);
    
    % Morphological technique
    % Dilate it so to connect the line to fill the object
    se90 = strel('line', 5, 90);
    se0 = strel('line', 5, 0);
    BWsdil = imdilate(BWs, [se90 se0]);
    BWsdil = imdilate(BWsdil, [se90 se0]);
    BWsdil = imdilate(BWsdil, [se90 se0]);
    %imshow(BWsdil);

    % Fill the hole to get the perfect object
    BWdfill = imfill(BWsdil, 'holes');
    %imshow(BWdfill);
    
    % Erode it back so that the hands object doesn't touch the border
    % because we want to eliminate the circle
    % Other technique can also be use to remove the circle
    seD = strel('diamond', 6);
    BWerode = imerode(BWdfill,seD);
    BWerode = imerode(BWerode,seD);
    %imshow(BWerode);
    
    % Clear the circle that attach to the border
    BWnobord = imclearborder(BWerode, 4);
    %imshow(BWnobord);
    
    % Get the row an column
    [row, column] = size(BWnobord);
    n1=10;
   
    % This is the part where we calculate where to crop the object

    % num_motion is the total sum of the value of pixel
    % in the image. Since BWfinal is in binary. The sum
    % is the total of all the white pixel.
    num_motion = sum(BWnobord(:));

    
    columnWeight = (ones(row,1)*[1:column]).*BWnobord;


    cMean = round(sum(columnWeight(:))/num_motion);

    a1 = sum(columnWeight(:).^2);
    a2 = (sum(columnWeight(:))^2)/num_motion;
    cStd = round(sqrt((a1-a2)/(num_motion-1)));

    rowWeight = ([1:row]'*ones(1,column)).*BWnobord;
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

    % After doint the necessary calculation, time to crop the object out
    Y=imcrop(BWnobord,[ColumnStart, RowStart,ColumnEnd-(ColumnStart),RowEnd-(RowStart)]);
    [row,column] = size(Y);
    Y = double(Y);

    imshow(Y);

    % use regionprops to get the Area, Centroid and Perimeter
    stats = regionprops(Y, 'Area', 'Centroid', 'Perimeter');

    % Check if there is no object detected
    if isempty(stats)
        % just pass if there is no object
    else
       
        % Get necessary feature from regionprops
        ObjectPerimeter = stats(1).Perimeter;
        ObjectArea = stats(1).Area;
        Y1=stats(1).Centroid;
        Y1=round(Y1);
        xc = Y1(1); yc=Y1(2);
        
        % Get max point for every 90 deegre angle
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


        % The part to get max point at every 10 degree in every quadrant
        for n=n1:n1:90-n1
            for i=1:column*3
   
                belahan = round(i*(cos((n/180)*pi)));
                titikbelahan=[xc+belahan,yc];
                tegak=round(sqrt((i^2)-(belahan^2)));
                titiksendeng=[xc+belahan,yc-tegak];
                TEGAK = yc-tegak;
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
                elseif TEGAK <= 0
                    TEGAK=TEGAK;
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

        %Save the distance in respective variable
        d0;a=dq1;d9;b=dq2;d18;c=dq3;d27;d=dq4;
        
        % Use to display the number of frame in every figure to display the
        % line
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

        % extract feature
        f=[xc,yc] % centroid
        % The max-point at every 10 degree
        g = [s0 ; q1(1,:) ; q1(2,:) ; q1(3,:) ; q1(4,:) ; q1(5,:) ; q1(6,:) ; q1(7,:) ; q1(8,:) ;
            s9 ; q2(1,:) ; q2(2,:) ; q2(3,:) ; q2(4,:) ; q2(5,:) ; q2(6,:) ; q2(7,:) ; q2(8,:) ;
            s18 ; q3(1,:) ; q3(2,:) ; q3(3,:) ; q3(4,:) ; q3(5,:) ; q3(6,:) ; q3(7,:) ; q3(8,:) ;
            s27 ;  q4(1,:) ; q4(2,:) ; q4(3,:) ; q4(4,:) ; q4(5,:) ; q4(6,:) ; q4(7,:) ; q4(8,:) ];
        e=[d0 a d9 b d18 c d27 d]; % the distance from centroid to the max point

        % Get the hand number
        if ii <= 1202
            handNumber = 1;
        elseif (ii > 1202) && (ii <= 1213)
            handNumber = 2;
        elseif (ii > 1213) && (ii <= 1236)
            handNumber = 3;
        elseif (ii > 1236) && (ii <= 1249)
            handNumber = 4;
        elseif (ii > 1249)
            handNumber = 5;
        else
            handNumber = -1;
        end

        %Put every feature in an array
        for i=1:36
            h(i,1) = ii;
            h(i,2) = f(1);
            h(i,3) = f(2);
            h(i,4) = g(i,1);
            h(i,5) = g(i,2);
            h(i,6) = e(1,i);
            h(i,7) = ObjectPerimeter;
            h(i,8) = ObjectArea;
            h(i,9) = handNumber;
        end

        % append the feature to existing array(hhh)
        hh=h;hhh=[hhh;hh];


     end
end

% Write the feature in array hhh to excel file
filename = 'C:\Users\lab E211\Desktop\labtest_50212116040.xlsx';
xlswrite(filename,hhh,1,'A2');