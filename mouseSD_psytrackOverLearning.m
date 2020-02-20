%% MouseSD - Psytrack model over learning

%% List of possible inputs we may want to provide!

% - Bias
% - Speed Left
% - Speed Right
% - PrevAnswer
% - PrevChoice
% - geoMean
% - geoRatio(signed)
% - running?

%% 

tempTrials = [d144trials.trials];

vl = [tempTrials.velXL];
vr = [tempTrials.velXR];

% y as 1 and 2. choice as -1 and 1;
y = [tempTrials.response];
y(y==1)=2; % convert right = 1 to = 2;
y(y==-1)=1; % convert left = -1 to = 1;
choice = [tempTrials.response];

% answers as -1 and 1
answers = NaN*size(choice);
leftAnswerIdx = find([tempTrials.geoRatio]<1);
rightAnswerIdx = find([tempTrials.geoRatio]>1);
answers(leftAnswerIdx)=-1;
answers(rightAnswerIdx)=1;



