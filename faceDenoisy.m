function faceDenoisy
import brml.*

Gx=32; Gy=26;
W0=defineWeight(Gx,Gy);

figure
load noisyface;noisy=xnoisy;
subplot(1,3,2);imagesc(noisy);title('noisy');

%load xclean
RGB=imread('face.jpg');
I=rgb2gray(RGB);
BW=imbinarize(I);
xclean=BW;
subplot(1,3,1);imagesc(xclean);title('clean');

%100 times' sampling
for k=1:10
    for j=1:10
        init=noisy((1+(k-1)*Gx):k*Gx,1+(j-1)*Gy:j*Gy);
        %partial denoisy
        b = 2*init(:)-1; % bias to favour the noisy image
        W=10*W0; % preference for neighbouring pixels to be in same state
        opts.maxit=1; opts.minit=1; opts.xinit=init(:);%pass x
        for loop=1:5      
        xrestored = brml.binaryMRFmap(W,b,1,opts);%b=2y-1
        opts.xinit=xrestored;
        noisy((1+(k-1)*Gx):k*Gx,1+(j-1)*Gy:j*Gy)=reshape(xrestored,Gx,Gy);
        %update noisy
        subplot(1,3,3);imagesc(noisy);colormap bone;title(['restored k=' num2str(k) ' j=' num2str(j)]);drawnow;
        end       
    end
end

finalStep1=xclean(321,:);%remain row
finalStep2=xclean(:,261:265);%remain colums
init=noisy(321,:);
b=2*init(:)-1;W0=defineWeight(1,265);W=10*W0;opts.xinit=finalStep1(:);
for loop=1:5      
        xrestored = brml.binaryMRFmap(W,b,1,opts);
        opts.xinit=xrestored;
        noisy(321,:)=reshape(xrestored,1,265);
        subplot(1,3,3);imagesc(noisy);colormap bone;title('clean remain row');drawnow;
end 
init=noisy(:,261:265);
b=2*init(:)-1;W0=defineWeight(321,5);W=10*W0;opts.xinit=finalStep2(:);
for loop=1:5      
        xrestored = brml.binaryMRFmap(W,b,1,opts);
        opts.xinit=xrestored;
        noisy(:,261:265)=reshape(xrestored,321,5);
        subplot(1,3,3);imagesc(noisy);colormap bone;title('clean remain colums');drawnow;
end
figure
imagesc(noisy);colormap bone;title('final restored');
end

function [W0]=defineWeight(Gx,Gy)
N=Gx*Gy;
st = reshape(1:N,Gx,Gy); % assign each grid point a state
W0=zeros(N,N);  

%detect & assign neighbours
import brml.*
for x = 1:Gx
    for y = 1:Gy
        if validgridposition(x+1,y,Gx,Gy); W0(st(x+1,y),st(x,y))=1; end
        if validgridposition(x-1,y,Gx,Gy); W0(st(x-1,y),st(x,y))=1; end
        if validgridposition(x,y+1,Gx,Gy); W0(st(x,y+1),st(x,y))=1; end
        if validgridposition(x,y-1,Gx,Gy); W0(st(x,y-1),st(x,y))=1; end
    end
end
end