function [u,v] = OFV1(im1,im2,s)
 
[rows,columns]=size(im1);
% fix height to 150 pixels.
height=300;
ratio_b2l=height/rows;
% width baru = ratio x widht lama
 
%tetapkan size
im1=imresize(im1,[height ratio_b2l*columns]);
im2=imresize(im2,[height ratio_b2l*columns]);
 
u = zeros(size(im1));
v = zeros(size(im2));
tu = zeros(size(im1));
tv = zeros(size(im2));
%mencari optical flow
[rows,columns]=size(im1);
 
%tentukan Ix,Iy dan It
 
% [AU,AV]= ComputeDerivatives2(u, v);
n= round( log10( 30 / min( rows,columns ) ) / log10( 0.9 ) );
[Ex, Ey, Et] = ComputeDerivatives(im1, im2);
% [u,v]=ComputeDerivatives2(u, v);
%menggunakan iteration dan smooth factor
for k=1:n
    for x=2:columns-1
        for y=2: rows-1
            %                 [u,v]=ComputeDerivatives2(u, v);
            AU(y,x)=(u(y,x-1)+u(y,x+1)+u(y-1,x)+u(y+1,x))/4;
            AV(y,x)=(v(y,x-1)+v(y,x+1)+v(y-1,x)+v(y+1,x))/4;
            A(y,x)=(Ex(y,x)*AU(y,x)+Ey(y,x)*AV(y,x)+Et(y,x));
            B(y,x)=(1+s*(Ex(y,x)*Ex(y,x)+Ey(y,x)*Ey(y,x)));
            tu(y,x)=AU(y,x)-(Ex(y,x)*s*(A(y,x)/B(y,x)));
            tv(y,x)=AV(y,x)-(Ey(y,x)*s*(A(y,x)/B(y,x)));
 
        end
    end
    for x=2:columns-1
        %         x
        for y=2:rows-1
            %             y
            u(y,x)=tu(y,x);
            v(y,x)=tv(y,x);
        end
    end
end
h=fspecial('gaussian',[5 5],1);
newu1=imfilter(u,h);
newv1=imfilter(v,h);
 
%menggunakan medfilter filter
%newu1=Reduce(Reduce(medfilt2(newu,[5 5])));
%newv1=Reduce(Reduce(medfilt2(newv,[5 5])));
[r,c]=size(newu1)

k=1;
 
for px=1:r
    for py=1:c
        sm(px,py)=sqrt(newu1(px,py)*newu1(px,py) +newv1(px,py)*newv1(px,py));
        if sm(px,py)>0.3
            posisicol(k)=px;
            posisirow(k)=py;
            u2(px,py)=newu1(px,py);
            v2(px,py)=newv1(px,py);
            u3(k)=newu1(px,py);
            v3(k)=newv1(px,py);
            k=k+1;
        else
            u2(px,py)=0;
            v2(px,py)=0;
 
        end
 
    end
end
