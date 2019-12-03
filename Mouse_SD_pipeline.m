%% Mouse Speed Discrimination analysis pipeline
%set(0,'DefaultFigureWindowStyle','docked');


folder = 'X:\ibn-vision\DATA\SUBJECTS\M19145\SDTraining\191202'
splitfold = split(folder, '\');
subj = splitfold{5};
seshDate = splitfold{7};

%% import csv files
[eventsRaw, paramsRaw, wheelRaw, licksRaw, nSessions] = importSessionFilesConcat(folder);

%% loop through sessions

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

activeTrials = trials(find([trials.type]=='activev2'));
geometricMeanSpeeds = unique([trials.geoMean]); meanSpeeds = [200 320];
validTrials = activeTrials(find([activeTrials.engaged]==1));

options             = struct;   % initialize as an empty struct
options.sigmoidName = 'gauss'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options.expType     = 'YesNo';

for ispeed = 1:numel(meanSpeeds)
    speed(ispeed).meanSpeed = meanSpeeds(ispeed);
    speed(ispeed).ratios = [];
    speed(ispeed).trials = ...
    validTrials(find([validTrials.geoMean]==meanSpeeds(ispeed)));
    speed(ispeed).ratios = unique([speed(ispeed).trials.geoRatio]);
    speed(ispeed).psigMatrix = [];
    
    for iratio = 1:numel(speed(ispeed).ratios)
        speed(ispeed).ratTrials(iratio).trials = ...
            speed(ispeed).trials(find([speed(ispeed).trials.geoRatio]==speed(ispeed).ratios(iratio)));
        
        
        speed(ispeed).psigMatrix(iratio,1) = (speed(ispeed).ratios(iratio));
        if speed(ispeed).psigMatrix(iratio,1) < 1
            speed(ispeed).psigMatrix(iratio,1) = -(1/speed(ispeed).psigMatrix(iratio,1));
        end
       
        speed(ispeed).psigMatrix(iratio,2) = numel(find([speed(ispeed).ratTrials(iratio).trials.response]==1));
        speed(ispeed).psigMatrix(iratio,3) = numel([speed(ispeed).ratTrials(iratio).trials]);
    end

    speed(ispeed).psigResult = psignifit(speed(ispeed).psigMatrix, options);
    figure
    plotPsych(speed(ispeed).psigResult);
    title(['Speed: ' num2str(speed(ispeed).meanSpeed)]);
    gca
    
end


%% plot unsigned psychometric curve
options             = struct;   % initialize as an empty struct
options.sigmoidName = 'gauss'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options.expType     = '2AFC';
options.poolxTol = 0.5;

for ispeed = 1:numel(meanSpeeds)
    for iratio = 1:numel(speed(ispeed).ratios)
        speed(ispeed).abspsigMatrix(iratio,1) = abs(log(speed(ispeed).ratios(iratio)));
        speed(ispeed).abspsigMatrix(iratio,2) = numel(find([speed(ispeed).ratTrials(iratio).trials.result]~=0));
        speed(ispeed).abspsigMatrix(iratio,3) = numel([speed(ispeed).ratTrials(iratio).trials]);
    end
    
    
    speed(ispeed).abspsigResult = psignifit(speed(ispeed).abspsigMatrix,options);
    figure
    plotPsych(speed(ispeed).abspsigResult);
    title(['(abs) Speed: ' num2str(speed(ispeed).meanSpeed)])
end
    
    
    
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