function [ H2 G ] = col_permutation( H1 )
%Encoding return a generator G and a matrix H2 up to column perputation
%   Detailed explanation goes here
% H1=N-K x N
[numOfRow,numOfCol]=size(H1);
%P=N-K x K
P=zeros(numOfRow,numOfCol-numOfRow);
%H2=[In-k P]
H2=H1;
% do column permutation
%In-k
I=eye(numOfRow);
for row=1:numOfRow  %ensure pivot
    for col=1:numOfCol   %find exchanged column   
        if H2(:,col)==I(:,row)
            temp=I(:,row);
            H2(:,row)=H2(:,col);
            H2(:,col)=temp;           
        end
    end   
end

P=H2(:,numOfRow+1:end);
%G=[P' Ik]'
G=[P' eye(numOfCol-numOfRow)]';
end


