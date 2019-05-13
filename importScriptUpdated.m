%% import different files from behaviour
% events (trial event times)
% trial Params (parameters of each trial)
% wheel (wheel input)
% Licks (lick inputs)

folder = 'X:\ibn-vision\DATA\SUBJECTS\M19027\Training\20190513'

[events, params, wheel, licks] = importSessionFiles(folder);
% check for duplicate files, in which case create seperate folders?

%% get wheel speed
% wheel struct, smth window type, windowSize(bins)
wheel = processWheel(wheel, 'gaussian', 10);

%% Process events
blockTags = {'passive', 'activeany', 'activenoabort', 'active'};
[events, licks] = processEvents(events, licks, blockTags);

%% Generate trial struct
trial = genTrialStruct(events, params, wheel, licks);


%% session metrics
blockTags = {'passive', 'activeany', 'activenoabort', 'active'};
[metrics,trial] = getSessionMetrics(trial, blockTags, 1); % plot flag

 

%% When are mice licking?
% need to define time periods of different epochs.
respWindowLength = 4;

epochs.stimOnNotMoving = [];
epochs.stimOnMoving = [];
epochs.respWindow = [];
epochs.ISI = [];

for itrial = 1:numel(events.sontimes)-1
    epochs.stimOnNotMoving = [epochs.stimOnNotMoving; trial(itrial).onTime, events.movetimes(itrial)];
    epochs.stimOnMoving = [epochs.stimOnMoving; events.movetimes(itrial), events.sofftimes(itrial)];
    epochs.respWindow = [epochs.respWindow; events.sofftimes(itrial), events.sofftimes(itrial)+respWindowLength]; % not meaningful for passive?
    epochs.ISI = [epochs.ISI; events.sofftimes(itrial)+2, trial(itrial+1).onTime];
end

% number of licks in:
% stim on not moving

licks = struct;
B1 = epochs.stimOnNotMoving;
B2 = epochs.stimOnMoving;
B3 = epochs.respWindow;
B4 = epochs.ISI;

% left licks
idx1 = false(size(events.lickTimeL));
idx2 = false(size(events.lickTimeL));
idx3 = false(size(events.lickTimeL));
idx4 = false(size(events.lickTimeL));

for ii = 1:length(events.lickTimeL)
  idx1(ii) = any((events.lickTimeL(ii)>B1(:,1))&(events.lickTimeL(ii)<B1(:,2)));
  idx2(ii) = any((events.lickTimeL(ii)>B2(:,1))&(events.lickTimeL(ii)<B2(:,2)));
  idx3(ii) = any((events.lickTimeL(ii)>B3(:,1))&(events.lickTimeL(ii)<B3(:,2)));
  idx4(ii) = any((events.lickTimeL(ii)>B4(:,1))&(events.lickTimeL(ii)<B4(:,2)));
end

licks.totals.stimOnNotMoving(1) = sum(idx1);
licks.totals.stimOnMoving(1) = sum(idx2);
licks.totals.respWindow(1) = sum(idx3);
licks.totals.ISI(1) = sum(idx4);

clear idx1 idx2 idx3 idx4

% right licks

% left licks
idx1 = false(size(events.lickTimeR));
idx2 = false(size(events.lickTimeR));
idx3 = false(size(events.lickTimeR));
idx4 = false(size(events.lickTimeR));

for ii = 1:length(events.lickTimeR)
  idx1(ii) = any((events.lickTimeR(ii)>B1(:,1))&(events.lickTimeR(ii)<B1(:,2)));
  idx2(ii) = any((events.lickTimeR(ii)>B2(:,1))&(events.lickTimeR(ii)<B2(:,2)));
  idx3(ii) = any((events.lickTimeR(ii)>B3(:,1))&(events.lickTimeR(ii)<B3(:,2)));
  idx4(ii) = any((events.lickTimeR(ii)>B4(:,1))&(events.lickTimeR(ii)<B4(:,2)));
end

licks.totals.stimOnNotMoving(2) = sum(idx1);
licks.totals.stimOnMoving(2) = sum(idx2);
licks.totals.respWindow(2) = sum(idx3);
licks.totals.ISI(2) = sum(idx4);

clear idx1 idx2 idx3 idx4

% lick frequency (#licks/time in epoch)

licks.freqs.stimOnNotMoving = sum(licks.totals.stimOnNotMoving)/sum(B1(:,2)-B1(:,1));
licks.freqs.stimOnMoving = sum(licks.totals.stimOnMoving)/sum(B2(:,2)-B2(:,1));
licks.freqs.respWindow = sum(licks.totals.respWindow)/sum(B3(:,2)-B3(:,1));
licks.freqs.ISI = sum(licks.totals.ISI)/sum(B4(:,2)-B4(:,1));

figure
hb = bar([licks.freqs.stimOnNotMoving, licks.freqs.stimOnMoving, licks.freqs.respWindow, licks.freqs.ISI], 'FaceColor','flat')
ylabel('mean lick frequency (Hz)')
a = gca
a.XTickLabel = [{'stat stim'}, {'moving stim'}, {'resp window'}, {'ISI'}];
hb.CData = [.8 .8 .8; .6 .6 .6; .4 .4 .4; .2 .2 .2]
box off
%a.XTickLabelRotation = 45
% want to check -> pre-emptive licks correct or not?

%% plot all trials in one figure

%% plot active any trials

lefttrials = []; righttrials =[];
for itrial = 1:numel(trial)
    if trial(itrial).velXL < trial(itrial).velXR
        lefttrials = [lefttrials; itrial];
    else
        righttrials = [righttrials; itrial];
    end
end

trialCounter = 0;
figure, hold on,
for ileft = 1:numel(lefttrials)
    trialCounter = trialCounter + 1;
    p = plot(trial(lefttrials(ileft)).licksL, repelem(trialCounter, 1, numel(trial(lefttrials(ileft)).licksL)), 'b*');
    p2= plot(trial(lefttrials(ileft)).licksR, repelem(trialCounter, 1, numel(trial(lefttrials(ileft)).licksR)), 'r*');
end
plot(-1:4, repelem(trialCounter + 0.5, 6, 1), 'k--')

for iright = 1:numel(righttrials)
    trialCounter = trialCounter + 1;
    plot(trial(righttrials(iright)).licksL, repelem(trialCounter, 1, numel(trial(righttrials(iright)).licksL)), 'b*')
    plot(trial(righttrials(iright)).licksR, repelem(trialCounter, 1, numel(trial(righttrials(iright)).licksR)), 'r*')
end

plot([-1 0 0 2 2 3 4],  [trialCounter+12 trialCounter+12 trialCounter+22 trialCounter+22 trialCounter+12 trialCounter+12 trialCounter+12], 'k-', 'LineWidth', 3)
plot([-1 1 1 2 2 3 4], [trialCounter+1 trialCounter+1 trialCounter+11 trialCounter+11 trialCounter+1 trialCounter+1 trialCounter+1], 'k--', 'LineWidth', 3)
plot([0 0], [0 trialCounter+12], 'k-.')
plot([1 1], [0 trialCounter+12], 'k-.')
plot([2 2], [0 trialCounter+12], 'k-.')

xlabel('trial time (s)'); xlim([-1 4])
ylabel('<--Right Trials      Left Trials-->', 'FontSize', 18);
a = gca;
a.YTick = [];



% plot individual trials

figure
for itrial = 1:numel(trial)

plot([-1 0 0 trial(itrial).stimOffTime trial(itrial).stimOffTime trial(itrial).stimOffTime+8],  [9 9 10 10 9 9], 'k-')
title(trial(itrial).trialType)
hold on
if trial(itrial).velXR < trial(itrial).velXL
    linetag = 'r-';
else linetag = 'b-';
end
plot([-1 trial(itrial).stimMoveTime trial(itrial).stimMoveTime trial(itrial).stimOffTime trial(itrial).stimOffTime trial(itrial).stimOffTime+8],  [8 8 8.9 8.9 8 8], linetag)
try
    if contains(trial(itrial).rewardTag, 'l')
        linetag = 'b--';
    elseif contains(trial(itrial).rewardTag, 'r')
        linetag = 'r--';
    end
    plot([-1 trial(itrial).rewardTime, trial(itrial).rewardTime, trial(itrial).rewardTime+0.1 trial(itrial).rewardTime+0.1 trial(itrial).stimOffTime+8],...
        [7 7 7.9 7.9 7 7],linetag)
catch
end

plot(trial(itrial).licksL, 6.5*ones(size(trial(itrial).licksL)), 'b*')
plot(trial(itrial).licksR, 6*ones(size(trial(itrial).licksR)), 'r*')
ylim([5.5 10.5])
xlim([-1 8])
hold off
pause
end