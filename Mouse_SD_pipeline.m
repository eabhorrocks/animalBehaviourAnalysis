%% Mouse Speed Discrimination analysis pipeline
%set(0,'DefaultFigureWindowStyle','docked');


folder = 'X:\ibn-vision\DATA\SUBJECTS\M19144\SDTraining\191203'
splitfold = split(folder, '\');
subj = splitfold{5};
seshDate = splitfold{7};

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

speed = plotPsychSDRatio(trials, options, options2);





%% plot unsigned psychometric curve





    
    
    
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