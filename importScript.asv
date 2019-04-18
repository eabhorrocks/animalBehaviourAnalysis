%% import different files from behaviour
% events (trial event times)
% trial Params (parameters of each trial)
% wheel (wheel input)
% Licks (lick inputs)

folder = 'C:\Users\edward.horrocks\Documents\GitHub\MouseBehaviourAnalysis\160419';

% Events
filePattern = fullfile(folder, 'Events*.*');
fileList = dir(filePattern);
if numel(fileList)>1
    error('multiple lick files detected')
end
eventsFileName = [fileList.folder, '\' fileList.name]

[events.tags,events.ts] = importEventsFile(eventsFileName);
events.eTime = datenum(events.ts);
referenceTime = events.eTime(1);
events.eTime = events.eTime - events.eTime(1);
events.eTime = events.eTime * 86400;

%% Trial Params
filePattern = fullfile(folder, 'TrialParams*.*');
fileList = dir(filePattern);
if numel(fileList)>1
    error('multiple lick files detected')
end
paramsFileName = [fileList.folder, '\' fileList.name]

[params.trialID,params.trialDuration,params.dotSize,params.dotCol1,...
    params.dotCol2,params.numDots1,params.numDots2,params.dotLifeBool,...
    params.dotLifetime,params.contrast,params.velXLeft,params.velYLeft,...
    params.cohLeft,params.velXRight,params.velYRight,params.cohRight,...
    params.response,params.ts] = importParamsFile(paramsFileName, 2, inf);

params.eTime = (datenum(params.ts) - referenceTime)*86400;

%% Equate trial params to each stim on

% need to find stimOn times which define each local trial time (i.e. t=0)
% then want to plot stim on, velocity (L and R)

events.sonidx = find(events.tags=="stimON");
events.sontimes = events.eTime(events.sonidx);

events.moveidx = find(events.tags=="dotsMOVE");
events.movetimes = events.eTime(events.moveidx);

events.soffidx = find(events.tags=="stimOFF");
events.sofftimes = events.eTime(events.soffidx);

events.rewardsidx = find(contains(events.tags, 'r') | contains(events.tags, 'l'));
events.rewardtimes = events.eTime(events.rewardsidx);
events.rewardstags = events.tags(events.rewardsidx);

trial = struct;
for itrial = 1:numel(events.sontimes)
    trial(itrial).onTime = events.sontimes(itrial);
    trial(itrial).stimMoveTime = events.movetimes(itrial) -  trial(itrial).onTime;
    trial(itrial).stimOffTime = events.sofftimes(itrial) - trial(itrial).onTime;
    trial(itrial).velXL = params.velXLeft(itrial);
    trial(itrial).velXR = params.velXRight(itrial);
    trial(itrial).response = params.response(itrial);
    % reward times (deals with manually given rewards which corrupt)
    [~, rewardidx] = min(abs(events.sofftimes(itrial) - events.rewardtimes));
    trial(itrial).rewardTime = events.rewardtimes(rewardidx) - trial(itrial).onTime;
    trial(itrial).rewardTag = events.rewardstags(rewardidx);
end


%% Wheel 
filePattern = fullfile(folder, 'Wheel*.*');
fileList = dir(filePattern);
if numel(fileList)>1
    error('multiple lick files detected')
end
wheelFileName = [fileList.folder, '\' fileList.name]

%% Licks 

% for now we are simulating lick times as elapsed time. To get to this
% point we need to convert to elapsed time w/ ref to reference time,
% extract which times are for L and which are for R.
events.lickTimeL =  sort(min(events.eTime) + (max(events.eTime)-min(events.eTime)).*rand(5000,1));
events.lickTimeR =  sort(min(events.eTime) + (max(events.eTime)-min(events.eTime)).*rand(5000,1));

for itrial = 1:numel(events.sontimes)
    % get time interval from ontime -1 to offtime + 2
    startTime = trial(itrial).onTime-1;
    stopTime = trial(itrial).onTime+trial(itrial).stimOffTime+2;
    trial(itrial).licksL = events.lickTimeL(events.lickTimeL < stopTime & events.lickTimeL > startTime)-trial(itrial).onTime;
    trial(itrial).licksR = events.lickTimeR(events.lickTimeR < stopTime & events.lickTimeR > startTime)-trial(itrial).onTime;
end

% for each trial grab licks from -1s before sonset to +2 after soffest?

% for each trial, grab a time interval (say -1 to + 4) of licks and wheel
% trace to overlay.
% maybe for each trial, we want a wheel field, which has trial-local time
% on row 1 and wheel values on row 2. Similar thing for 



%% plot individual trials

figure
for itrial = 1:100

plot([-1 0 0 trial(itrial).stimOffTime trial(itrial).stimOffTime trial(itrial).stimOffTime+1],  [9 9 10 10 9 9], 'k-')
hold on
if trial(itrial).velXR < trial(itrial).velXL
    linetag = 'r-';
else linetag = 'b-';
end
plot([-1 trial(itrial).stimMoveTime trial(itrial).stimMoveTime trial(itrial).stimOffTime trial(itrial).stimOffTime trial(itrial).stimOffTime+1],  [8 8 8.9 8.9 8 8], linetag)

if contains(trial(itrial).rewardTag, 'l')
    linetag = 'b--';
elseif contains(trial(itrial).rewardTag, 'r')
    linetag = 'r--';
end
plot([-1 trial(itrial).rewardTime, trial(itrial).rewardTime, trial(itrial).rewardTime+0.1 trial(itrial).rewardTime+0.1 trial(itrial).stimOffTime+1],...
    [7 7 7.9 7.9 7 7],linetag)

plot(trial(itrial).licksL, 6.5*ones(size(trial(itrial).licksL)), 'b*')
plot(trial(itrial).licksR, 6*ones(size(trial(itrial).licksR)), 'r*')
ylim([5.5 10.5])
xlim([-1 4])
hold off
pause
end