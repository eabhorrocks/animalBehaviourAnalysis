%% Mouse Speed Discrimination analysis pipeline
%set(0,'DefaultFigureWindowStyle','docked');


folder = 'X:\ibn-vision\DATA\SUBJECTS\M19144\SDTraining\191211'
%folder = 'X:\DATA\SUBJECTS\M19145\SDTraining\191204'

splitfold = split(folder, '\');
%subj = splitfold{5};
%seshDate = splitfold{7};

%% import csv files
[eventsRaw, paramsRaw, wheelRaw, licksRaw, nSessions] = importSessionFilesConcat(folder);

%% loop through sessions, generate trial struct

for iSession = 1:nSessions
    
    % process wheel (wheel struct, smth window type, windowSize(bins))
    wheelProcessed = processWheel(wheelRaw(iSession), 'gaussian', 10);
    wheel(iSession) = wheelProcessed;
    clear wheelProcessed
    
    % Process events
    [eventsProcessed, licksProcessed] = processEvents(eventsRaw(iSession), licksRaw(iSession));
    events(iSession) = eventsProcessed; 
    licks(iSession) = licksProcessed;
    clear licksProcessed eventsProcessed
    
    % Generate trial struct
    % for multiple sessions, want to just catenate on the end
    if iSession ~=1
        trials_temp = genTrialStruct(events(iSession), paramsRaw(iSession), wheel(iSession), licks(iSession));
        trials = [trials, trials_temp];
    else
    trials = genTrialStruct(events(iSession), paramsRaw(iSession), wheel(iSession), licks(iSession));
    end
    
end

%%
activeTrials = trials(find([trials.type]=='activev2'));
meanSpeeds = unique([trials.geoMean]);
validTrials = activeTrials(find([activeTrials.engaged]==1));

%% plot psychometric curves for each speed

% options for signed psychometric curves
options             = struct;   % initialize as an empty struct
options.sigmoidName = 'gauss'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options.expType     = 'YesNo';

% options for absolute value psychometric curve
options             = struct;   % initialize as an empty struct
options2.sigmoidName = 'gauss'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options2.expType     = '2AFC';
options2.poolxTol = 0.1;
options2.poolMaxGap = inf;
options2.poolMaxLength = inf;
options2.nblocks = 1;

speed = plotPsychSDRatio(validTrials, options, options2);

%% metrics

figure
% get diff trial types
correctTrials = validTrials(find([validTrials.result] ~= 0));
incorrectTrials = validTrials(find([validTrials.result] == 0));
runningTrials = validTrials(find([validTrials.runbool]==1));
mixedTrials = validTrials(find([validTrials.runbool]==-1));
statTrials = validTrials(find([validTrials.runbool]==0));

% running
nRunning = numel(find([validTrials.runbool]==1))
nStat = numel(find([validTrials.runbool]==0))
nMixed = numel(find([validTrials.runbool]==-1))

% 
figure
histogram([correctTrials.meanRunSpeed], 20, 'FaceAlpha', 0.5), hold on
histogram([incorrectTrials.meanRunSpeed], 20, 'FaceAlpha', 0.5)
title('mean run speed'), box off
hold off

figure
histogram([correctTrials.varRunSpeed], 20, 'FaceAlpha', 0.5), hold on
histogram([incorrectTrials.varRunSpeed], 20, 'FaceAlpha', 0.5)
title('var run speed'), box off
hold off


%%
% speedrun = plotPsychSDRatio(runningTrials, options, options2);
% speedmixed = plotPsychSDRatio(statTrials, options, options2);





    
    
    
    %% plot all trials
% psigMatrixAll = [speed(1).psigMatrix; speed(2).psigMatrix]
% psigresultAll = psignifit(psigMatrixAll);
% figure
% plotPsych(psigresultAll)





    
    % session metrics
    %[metrics,trial] = getSessionMetrics(trial, blockTags, 1, saveflag); % plot flag, save flag
%     
%     % plot blocks trial-centric
%     for i = 1:numel(blockTags)
%         plotTrials.(blockTags{i}) = trial(metrics.blockidx.(blockTags{i}));
%         if ~isempty(plotTrials.(blockTags{i}))
%             plotSDTrialBlock(plotTrials.(blockTags{i}), blockTags{i}, saveflag); % saveflag
%         end
%     end
%     
% end