function demoFACEclean
%DEMOFACECLEAN demo of image denoising using a binary state Markov Random Field

import brml.*
%load xclean
RGB=imread('face.jpg');
I=rgb2gray(RGB);
BW=imbinarize(I);%method in image processing toolbox, convert gray to binary
xclean=BW;
subplot(1,3,1);imagesc(xclean);colormap bone;title('clean');

Gx=321; Gy=265; N=Gx*Gy;
st = reshape(1:N,Gx,Gy); % assign each grid point a state

disp('building the MRF...')
W0=sparse(N,N);
for x = 1:Gx
    for y = 1:Gy
        if validgridposition(x+1,y,Gx,Gy); W0(st(x+1,y),st(x,y))=1; end
        if validgridposition(x-1,y,Gx,Gy); W0(st(x-1,y),st(x,y))=1; end
        if validgridposition(x,y+1,Gx,Gy); W0(st(x,y+1),st(x,y))=1; end
        if validgridposition(x,y-1,Gx,Gy); W0(st(x,y-1),st(x,y))=1; end
    end
end

load('noisyface');noisy=xnoisy;
subplot(1,3,2);imagesc(noisy);title('noisy');

b = 2*noisy(:)-1; % bias to favour the noisy image
W=10*W0; % preference for neighbouring pixels to be in same state
opts.maxit=1; opts.minit=1; opts.xinit=noisy(:);

for loop=1:10
    [xrestored El] = brml.binaryMRFmap(W,b,1,opts);
    E(loop)=El;
    figure(1)
    subplot(1,3,3); imagesc(reshape(xrestored,Gx,Gy)); title(['restored ' num2str(loop)]); drawnow
    opts.xinit=xrestored;
    figure(2);
    plot(E,'-o'); title('Objective function value'); drawnow
end
