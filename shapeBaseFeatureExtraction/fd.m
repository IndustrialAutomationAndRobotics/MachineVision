clear all

% Read the video file
vidIn = VideoReader('C:\Users\lab E211\Desktop\MachineVision-master\tangan.mp4');
dataset4 = [];
pic = read(vidIn, 1260);
%imshow(pic);

images = rgb2gray(pic);
bw = im2bw(images);

seD = strel('diamond', 3);
bw = imdilate(bw,seD);

stats = regionprops(bw, 'Area');
areaObj1 = stats(1).Area;
areaObj2 = stats(2).Area;

if (areaObj1 < areaObj2)
    bw = bwareaopen(bw, areaObj1+10);
else
    bw = bwareaopen(bw, areaObj2+10);
end

figure(1),imshow(bw);
hold on
boundaries = bwboundaries(bw);

for k=1:1
    b = boundaries{k};
    plot(b(:,2),b(:,1),'b','LineWidth', 3);
end
hold off

z=complex(b(:,2),b(:,1));

% calculate centroid
x=real(z);
y=imag(z);
xc = sum(x)/length(x);
yc = sum(y)/length(y);
s1=[xc yc];
ss1=complex(xc,yc);
z_cent=z-ss1;
zz_cent=fft(z_cent);
zz_cent(1);
magni=abs((zz_cent));
figure(2),plot(magni)
figure(100)
semilogx(magni)
%pause

maksima=max(magni);
pertama=magni(1);
beza = maksima - pertama;
n=size(zz_cent);


n1=zz_cent(1:30)/abs(zz_cent(1));
n2=zz_cent(n-30:n)/abs(zz_cent(1));
nn1 = abs(zz_cent(1:30))/abs(zz_cent(1));
nn2=abs(zz_cent(n-30:n))/abs(zz_cent(1));
n3=[n1;n2];
fc_v=[nn1;nn2];
fc_v=fc_v.';
reconc=ifft(n3);
reconc=[reconc; reconc(1)];
figure(3), plot(reconc,'-');
axis ij
axis equal
hold on
x=real(reconc); y=imag(reconc);
xc=sum(x)/length(x);
yc=sum(y)/length(y);
hold off
simpan=[fc_v];
simpan=abs(simpan);
dataset4=[dataset4 simpan];