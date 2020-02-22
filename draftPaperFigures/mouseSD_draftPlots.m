%% draft plots for behaviour paper
set(0,'DefaultFigureWindowStyle','docked')

%% plot of total trials

nTrialsAll = padcat([day144.nActiveTrials], [day145.nActiveTrials]);
nTrialsMean = nanmean(nTrialsAll);

figure
plot(nTrialsAll', 'Color', [.7 .7 .7]), hold on
plot(nTrialsMean, 'Color', 'k', 'LineWidth', 2)
xlabel('Session num'), ylabel('nTrials');

%% training details - nTrials

fieldNames = {'nEngagedTrials', 'pEngaged', 'pRunning'} 

for i=1:numel(fieldNames)
    
    fieldName = fieldNames{i};

allSubVals = padcat([day144.(fieldName)], [day145.(fieldName)]);
meanVals = nanmean(allSubVals);
subplot(3,1,i)
plot(allSubVals', 'Color', [.7 .7 .7]), hold on
plot(meanVals, 'Color', 'k', 'LineWidth', 2)
xlabel('Session num'), ylabel(fieldName);
title([fieldName ' over training'])


end

subplot(311)
a = gca;
a.XTick = [];
xlabel([]);
subplot(312)
a = gca;
a.XTick = [];
xlabel([]);
subplot(313)
ylim([0 1])


%% training details - performance
fieldNames = {'bias', 't70'} 

for i=1:numel(fieldNames)
    
    fieldName = fieldNames{i};

allSubVals = padcat(abs([day144.(fieldName)]), abs([day145.(fieldName)]));
meanVals = nanmean(allSubVals);
subplot(2,1,i)
plot(allSubVals', 'Color', [.7 .7 .7]), hold on
plot(meanVals, 'Color', 'k', 'LineWidth', 2)
xlabel('Session num'), ylabel(fieldName);
title([fieldName ' over training'])

end

subplot(211)
a = gca;
xlabel([]);
a.XTick = [];



%% thresholds for speed and run/walk

m144_allcat = cat(3,[day144(end-3).speedT70Array],[day144(end-2).speedT70Array],...
    [day144(end-1).speedT70Array], [day144(end).speedT70Array]);

m145_allcat = cat(3,[day145(end-4).speedT70Array],[day145(end-3).speedT70Array],...
    [day145(end-2).speedT70Array],[day145(end-1).speedT70Array],...
    [day145(end).speedT70Array]);


m144_means = nanmean(m144_allcat,3);
m145_means = nanmean(m145_allcat,3);

figure, hold on
for i = 1:4
    plot([i-0.2, i+0.2], [m145_means(1,i), m145_means(2,i)], '-', 'Color', [.7 .7 .7])
    plot([i-0.2], [m145_means(1,i)], 'ko', 'MarkerFaceColor', 'r')
    plot([i+0.2], [m145_means(2,i)], 'ko', 'MarkerFaceColor', 'g')
end

for i = 1:4
    plot([i-0.2, i+0.2], [m144_means(1,i), m144_means(2,i)], '-', 'Color', [.7 .7 .7])
    plot([i-0.2], [m144_means(1,i)], 'ks', 'MarkerFaceColor', 'r')
    plot([i+0.2], [m144_means(2,i)], 'ks', 'MarkerFaceColor', 'g')
end

ylabel('70% Threshold (log speed ratio)')
xlabel('Geometric Mean Speed')
title('Performance over speed and state')
a = gca;
a.XTick = [1,2,3,4];
a.XTickLabel = {'100', '200', '300', '400'}
ylim([0 2.2]);


%% plot left and right trials separately

leftTrials = validTrials(find([validTrials.geoRatio]<1));
rightTrials = validTrials(find([validTrials.geoRatio]>1));

leftHandle = plotSDenbloc(leftTrials,[],0);
xlim([-1 7])
ylabel([])
ylim([0 450])

rightHandle = plotSDenbloc(rightTrials,[],0);
xlim([-1 7])
ylabel([])
ylim([0 450])


allTrials = plotSDenbloc(validTrials,[],0);
xlim([-1 6.95])
ylabel([])
ylim([0 900])
set(gca, 'Ycolor', 'w')
set(gca, 'YTick', [])

%% plot all trials as psychometric curve
% options for signed psychometric curves
options             = struct;   % initialize as an empty struct
options.sigmoidName = 'gauss'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options.expType     = 'YesNo';
plotPsychSDRatioAllTrials(validTrials, options)



%% SPLIT BY SPEED AND STATE
options             = struct;   % initialize as an empty struct
options.sigmoidName = 'gauss'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options.expType     = 'YesNo';

load('m145_4speeds.mat')
load('m144_4speeds.mat')
allTrials = [day144_4speeds.trials, day145_4speeds.trials];
RunTrials = allTrials(find([allTrials.runbool]==1));
StatTrials = allTrials(find([allTrials.runbool]==0));

plotPsychSDRatio_RunvsStat(RunTrials, StatTrials, options)


%%

load('m145_alltrials.mat')

