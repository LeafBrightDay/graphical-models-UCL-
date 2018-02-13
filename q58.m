function q58
% This approach is based on HMMviterbi%
import brml.*
% Indexing %
% C david, anton, fred, jim, barry C  barber, ilsung, fox, chain, fitzwilliam, 
% 1 2      7     12     16   19   |24|25      31      37   40     45
% quinceadams grafvonunterhosen
% 56          67              83   

% ph1 %
clear all;
ph1 = zeros(83,1);
ph1(1,1) = 1;
pvgh = zeros(83,26);
phghm = zeros(83,83);


% phghm %
randChar = [1,24];
firstLetter_firstName = [2,7,12,16,19]; % 5
lastLetter_firstName =    [6,11,15,18,23];
firstLetter_LastName = [25,31,37,40,45,56,67]; % 7
lastLetter_LastName  =    [30,36,39,44,55,66,83];
% C1
phghm(1,1) = 0.8;
phghm(firstLetter_firstName,1) = 0.2/5;
% C2
phghm(24,24) = 0.8;
phghm(firstLetter_LastName,24) = 0.2/7;
% first name
for col_idx = 2:23
    if ismember(col_idx, lastLetter_firstName(:))
        phghm(24,col_idx) = 1;
    else
        phghm(col_idx+1, col_idx) = 1;
    end
end
% last name
for col_idx = 25:83
    if ismember(col_idx, lastLetter_LastName(:))
        phghm(1,col_idx) = 1;
    else
        phghm(col_idx+1, col_idx) = 1;
    end
end
        
% pvgh %
alphabet = ['abcdefghijklmnopqrstuvwxyz'];
letters = ['CdavidantonfredjimbarryCbarberilsungfoxchainfitz'...
    'williamquinceadamsgrafvonunterhosen'];
% C1, C2
pvgh(randChar(1),:) = 1/26;
pvgh(randChar(2),:) = 1/26;
% first name
for row_idx = 2:23
    target = strfind(alphabet, letters(row_idx));
    pvgh(row_idx, :) = 0.7/25;
    pvgh(row_idx, target) = 0.3;
end
% last name
for row_idx = 25:83
    target = strfind(alphabet, letters(row_idx));
    pvgh(row_idx, :) = 0.7/25;
    pvgh(row_idx, target) = 0.3;
end

% prepare data to be analysed %
v= load('noisystring');
flat_v = struct2cell(v);
str_v = flat_v{1};

charSet = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n',...
    'o','p','q','r','s','t','u','v','w','x','y','z'};
numArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26];
charMap = containers.Map(charSet,numArray);

num_v = [];
for i = 1:length(str_v)
    num_v = [num_v charMap(str_v(i))];
end

% apply HMMviterbi %
clean_seq = HMMviterbi(num_v,phghm,ph1,pvgh');
numSet = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26};
charArray = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n',...
    'o','p','q','r','s','t','u','v','w','x','y','z'];
 
% generate occuring sequence of first name and last name respectively %
% represented by index of first letter of first name/ last name
i = 2;
firstNameSeq = [];
lastNameSeq = [];
while i < length(str_v)
    if clean_seq(i-1)==1 && clean_seq(i)>1
        firstNameSeq = [firstNameSeq,clean_seq(i)];
    end
    if clean_seq(i-1)==24 && clean_seq(i)>24
        lastNameSeq = [lastNameSeq, clean_seq(i)];
    end    
    i = i + 1;
end
pairsList = {};
for i = 1:length(lastNameSeq)
    pair = strcat(num2str(firstNameSeq(i)),num2str(lastNameSeq(i)));
    pairsList{end+1} = pair;
end

% count occurance for each pair %
xx = pairsList; 
a=unique(xx,'stable');
b=cellfun(@(x) sum(ismember(xx,x)),a,'un',0);

% generate occurance matrix %
occurance = containers.Map(a,b);
occurance_matrix = zeros(length(firstLetter_firstName),...
    length(firstLetter_LastName));
for i = 1:length(firstLetter_firstName)
    for j = 1:length(firstLetter_LastName)
        pair = strcat(num2str(firstLetter_firstName(i)),...
                    num2str(firstLetter_LastName(j)));
        occurance_matrix(i,j) = occurance(pair);
    end
end

disp(occurance_matrix)


