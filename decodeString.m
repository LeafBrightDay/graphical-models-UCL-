function decodeString
import brml.*

%step1: assign state
%first name
name{1}='david';
name{2}='anton';
name{3}='fred';
name{4}='jim';
name{5}='barry';
%surname
name{6}='barber';
name{7}='ilsung';
name{8}='fox';
name{9}='chain';
name{10}='fitzwilliam';
name{11}='quinceadams';
name{12}='grafvonunterhosen';

for k=1:12
     Name{k}=name2num(name{k});
end

firstname=1:5; % 5 first names
surname=6:12; % 7 surnames

namestate=1:12; % name states (1 per name)
generalstate=13:15; % c1 c2 c1

numOfst=generalstate(end); % total number of pattern+general states

% make the transistion matrix:
tran=zeros(numOfst,numOfst);
tran(generalstate(1),generalstate(1))=0.8; % not started firstname
for m=firstname
    tran(namestate(m),generalstate(1))=0.2/length(firstname); % into a firstname
    tran(generalstate(2),namestate(m))=1; % out of firstname
end
tran(generalstate(2),generalstate(2))=0.8; % not start surname
for n=surname
    tran(namestate(n),generalstate(2))=0.2/length(surname);
    tran(generalstate(3),namestate(n))=1;
end
tran(generalstate(1),generalstate(3))=1;



