clear all;
H1=[1,1,1,1,0,0;0,0,1,1,0,1;1,0,0,1,1,0];
[H2,G]=col_permutation(H1);
disp('H = ');
disp(H2);
disp('G =');
disp(G);

%verify
V=mod(H2*G,2);
disp(V);
