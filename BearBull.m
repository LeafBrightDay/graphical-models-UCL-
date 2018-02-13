function BearBull
import brml.*
%define state. 1 for bear, 2 for bull
[bear, bull]=assign(1:2); 
%define transition matrix
transit(bear,bear)=0.8;
transit(bull,bear)=0.2;
transit(bull,bull)=0.7;
transit(bear,bull)=0.3;
%define price values
price=1:100; 
%load pbull, pbear, p
load BearBullproblem
T=length(p); % length of timeseries

%step1: Filtering p(ht|v1:t)
[htm, ht, vtm, vt]=assign(1:4);  %htm: hidden var(state) at t=m 
%vtm: visible var(price) at t=m
%array is the brml data structure
transition=array([ht htm],transit);%transition distribution 2x2 show state change
for st=1:2
    for ptm=price       %price at t=m
        for pt=price
            if st==bull
            priceTransit(pt,ptm,st)=pbull(pt,ptm);%the probability of price change in bull state
            else
            priceTransit(pt,ptm,st)=pbear(pt,ptm);
            end
        end
    end
end
emission=array([vt vtm ht],priceTransit);%emission distribution 100x100x2 show price change
%initial state with uniform distribution 0.5
f(:,1)=[0.5 0.5]';
filt=array(1,[0.5 0.5]);
for t=2:T
    filt=condpot(setpot(emission,[vtm vt],[p(t-1) p(t)])*transition*filt,ht); % filtered update
    f(:,t)=filt.table;
    filt.variables=1; %reset the filtered distribution 
end

% Step2: prediction p(ht|v1:s) t>s
predh=condpot(filt*transition,ht); % latent state prediction
predv=condpot(setpot(emission,vtm,p(T))*predh,vt); %  marginal p(vt)
u=0; sqU=0;
for i=price
    u=u+predv.table(i)*(i-p(T)); % expected gain
    sqU=sqU+predv.table(i)*(i-p(T)).^2; % expected squared gain
end
fi=figure;
t=uitable(fi,'Data',predv.table,'position',[50 50 140 300]);
t.ColumnName={'price'};
fprintf(1,'Expected price gain = %f\n', u); % total expected gain
fprintf(1,'Expected price gain standard deviation = %f\n', sqrt(sqU-u^2));