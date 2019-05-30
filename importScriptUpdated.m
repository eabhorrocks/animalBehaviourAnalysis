%% set folder and tags of blocks
folder = 'X:\ibn-vision\DATA\SUBJECTS\M19028\Training\20190529'
saveflag = 0;
blockTags = {'passive', 'activeany', 'activenoabort', 'active', 'activevary','activevaryL'};

splitfold = split(folder, '\');
subj = splitfold{5};
seshDate = splitfold{7};
dirName = [subj '_' seshDate];
mkdir('C:\Users\edward.horrocks\Documents\GitHub\animalBehaviourAnalysis\FIGURES',...
    dirName)
newDir = ['C:\Users\edward.horrocks\Documents\GitHub\animalBehaviourAnalysis\FIGURES\',...
    dirName];
cd(newDir)
set(0,'DefaultFigureWindowStyle','docked')

%% import csv files

[events, params, wheel, licks] = importSessionFiles(folder);
% check for duplicate files, in which case create seperate folders?
% auto-catenate files would be nice.
%% get wheel speed
% wheel struct, smth window type, windowSize(bins)
wheel = processWheel(wheel, 'gaussian', 10);

%% Process events
[events, licks] = processEvents(events, licks, blockTags);

%% Generate trial struct
trial = genTrialStruct(events, params, wheel, licks);

%% session metrics
blockTags = {'passive', 'activeany', 'activenoabort', 'active','activevary', 'activevaryL'};
[metrics,trial] = getSessionMetrics(trial, blockTags, 1, saveflag); % plot flag, save flag

%% plot blocks trial-centric
for i = 1:numel(blockTags)
    plotTrials.(blockTags{i}) = trial(metrics.blockidx.(blockTags{i}));
    if ~isempty(plotTrials.(blockTags{i}))
        plotSDTrialBlock(plotTrials.(blockTags{i}), blockTags{i}, saveflag); % saveflag
    end
end

%% plot all full-active trials together, with speed map colourcoded
plotSDActiveTrials(trial, [subj ' ' seshDate], saveflag)

%% session as time series
scrollPlotHandle = plotSessionAsSeriesLABMEETING(events, params, trial, wheel, licks, 1); % saveflag


%%
%% plot psychometric curves

activeTrialIndexes = sort([metrics.blockidx.activevary, metrics.blockidx.active, metrics.blockidx.activevaryL]);
allActiveTrials = trial(activeTrialIndexes);

validRes = [0 1 2];
idx = ismember([allActiveTrials.response], validRes);
validTrials = allActiveTrials(idx);

ptrials = struct();

for i = 1:numel(validTrials)
    ptrials(i).delv = abs(validTrials(i).velXR)-abs(validTrials(i).velXL);
    ptrials(i).response = validTrials(i).response;
    if (ptrials(i).response == 2) || (ptrials(i).delv < 0 && ptrials(i).response==0)
        ptrials(i).rresp = 1;
    else
        ptrials(i).rresp = 0;
    end
end

pt = struct();

speedDiffs = unique([ptrials.delv]);
for i = 1:numel(speedDiffs)
    pt(i).sd = speedDiffs(i);
    pt(i).trials = ptrials([ptrials.delv]==speedDiffs(i));
    pt(i).nTrials = numel(pt(i).trials);
    pt(i).nR = sum([pt(i).trials.rresp]);
    pt(i).propR = pt(i).nR/pt(i).nTrials;
end
propR = [pt.propR];
speedDiffs = speedDiffs;

% figure, hold on
% for i = 1:numel(speedDiffs)
% plot(speedDiffs(i), propR(i), 'bo', 'MarkerSize', pt(i).nTrials, 'MarkerFacecolor', 'b')
% end
figure
 %First we need the data in the format (x | nCorrect | total)
pSMatrix = [speedDiffs', [pt.nR]', [pt.nTrials]'];

options             = struct;   % initialize as an empty struct
options.sigmoidName = 'logistic'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options.expType     = 'YesNo';
psResult = psignifit(pSMatrix,options);

plotOptions.dataColor      = [0,105/255,170/255];  % color of the data
plotOptions.plotData       = 1;                    % plot the data?
plotOptions.lineColor      = [0,0,0];              % color of the PF
plotOptions.lineWidth      = 2;                    % lineWidth of the PF
plotOptions.xLabel         = 'Speed Difference of Right Dots vs Left Dots';     % xLabel
plotOptions.yLabel         = 'Proportion Right Response';    % yLabel
%plotOptions.labelSize      = 15;                   % font size labels
%plotOptions.fontSize       = 10;                   % font size numbers
%plotOptions.fontName       = 'Helvetica';          % font
%plotOptions.tufteAxis      = false;                % use special axis
%plotOptions.plotAsymptote  = true;                 % plot Asympotes 
%plotOptions.plotThresh     = true;                 % plot Threshold Mark
%plotOptions.aspectRatio    = false;                % set aspect ratio
%plotOptions.extrapolLength = .2;                   % extrapolation percentage
%plotOptions.CIthresh       = false;                % draw CI on threhold
%plotOptions.dataSize       = 10000./sum(result.data(:,3)) % size of the data-dots
plotPsych(psResult, plotOptions);
box off
grid on

%% dev catenate
% 
% for i= 1:6
%     
% pt3(i).sd = pt(i).sd;
% pt3(i).nTrials = pt(i).nTrials+pt2(i).nTrials;
% pt3(i).nR = pt(i).nR + pt2(i).nR;
% pt3(i).propR = pt(i).nR/pt(i).nTrials;
% 
% end
% 
% propR = [pt3.propR];
% 
% figure, hold on
% for i = 1:numel(speedDiffs)
% plot(speedDiffs(i), propR(i), 'bo', 'MarkerSize', pt(i).nR, 'MarkerFacecolor', 'b')
% end

% %% When are mice licking?
% % need to define time periods of different epochs.
% respWindowLength = 4;
% 
% epochs.stimOnNotMoving = [];
% epochs.stimOnMoving = [];
% epochs.respWindow = [];
% epochs.ISI = [];
% 
% for itrial = 1:numel(events.sontimes)-1
%     epochs.stimOnNotMoving = [epochs.stimOnNotMoving; trial(itrial).onTime, events.movetimes(itrial)];
%     epochs.stimOnMoving = [epochs.stimOnMoving; events.movetimes(itrial), events.sofftimes(itrial)];
%     epochs.respWindow = [epochs.respWindow; events.sofftimes(itrial), events.sofftimes(itrial)+respWindowLength]; % not meaningful for passive?
%     epochs.ISI = [epochs.ISI; events.sofftimes(itrial)+2, trial(itrial+1).onTime];
% end
% 
% % number of licks in:
% % stim on not moving
% 
% licks = struct;
% B1 = epochs.stimOnNotMoving;
% B2 = epochs.stimOnMoving;
% B3 = epochs.respWindow;
% B4 = epochs.ISI;
% 
% % left licks
% idx1 = false(size(events.lickTimeL));
% idx2 = false(size(events.lickTimeL));
% idx3 = false(size(events.lickTimeL));
% idx4 = false(size(events.lickTimeL));
% 
% for ii = 1:length(events.lickTimeL)
%     idx1(ii) = any((events.lickTimeL(ii)>B1(:,1))&(events.lickTimeL(ii)<B1(:,2)));
%     idx2(ii) = any((events.lickTimeL(ii)>B2(:,1))&(events.lickTimeL(ii)<B2(:,2)));
%     idx3(ii) = any((events.lickTimeL(ii)>B3(:,1))&(events.lickTimeL(ii)<B3(:,2)));
%     idx4(ii) = any((events.lickTimeL(ii)>B4(:,1))&(events.lickTimeL(ii)<B4(:,2)));
% end
% 
% licks.totals.stimOnNotMoving(1) = sum(idx1);
% licks.totals.stimOnMoving(1) = sum(idx2);
% licks.totals.respWindow(1) = sum(idx3);
% licks.totals.ISI(1) = sum(idx4);
% 
% clear idx1 idx2 idx3 idx4
% 
% % right licks
% 
% % left licks
% idx1 = false(size(events.lickTimeR));
% idx2 = false(size(events.lickTimeR));
% idx3 = false(size(events.lickTimeR));
% idx4 = false(size(events.lickTimeR));
% 
% for ii = 1:length(events.lickTimeR)
%     idx1(ii) = any((events.lickTimeR(ii)>B1(:,1))&(events.lickTimeR(ii)<B1(:,2)));
%     idx2(ii) = any((events.lickTimeR(ii)>B2(:,1))&(events.lickTimeR(ii)<B2(:,2)));
%     idx3(ii) = any((events.lickTimeR(ii)>B3(:,1))&(events.lickTimeR(ii)<B3(:,2)));
%     idx4(ii) = any((events.lickTimeR(ii)>B4(:,1))&(events.lickTimeR(ii)<B4(:,2)));
% end
% 
% licks.totals.stimOnNotMoving(2) = sum(idx1);
% licks.totals.stimOnMoving(2) = sum(idx2);
% licks.totals.respWindow(2) = sum(idx3);
% licks.totals.ISI(2) = sum(idx4);
% 
% clear idx1 idx2 idx3 idx4
% 
% % lick frequency (#licks/time in epoch)
% 
% licks.freqs.stimOnNotMoving = sum(licks.totals.stimOnNotMoving)/sum(B1(:,2)-B1(:,1));
% licks.freqs.stimOnMoving = sum(licks.totals.stimOnMoving)/sum(B2(:,2)-B2(:,1));
% licks.freqs.respWindow = sum(licks.totals.respWindow)/sum(B3(:,2)-B3(:,1));
% licks.freqs.ISI = sum(licks.totals.ISI)/sum(B4(:,2)-B4(:,1));
% 
% figure
% hb = bar([licks.freqs.stimOnNotMoving, licks.freqs.stimOnMoving, licks.freqs.respWindow, licks.freqs.ISI], 'FaceColor','flat')
% ylabel('mean lick frequency (Hz)')
% a = gca
% a.XTickLabel = [{'stat stim'}, {'moving stim'}, {'resp window'}, {'ISI'}];
% hb.CData = [.8 .8 .8; .6 .6 .6; .4 .4 .4; .2 .2 .2]
% box off
% %a.XTickLabelRotation = 45
% % want to check -> pre-emptive licks correct or not?
% 
