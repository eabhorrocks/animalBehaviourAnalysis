function trial = genTrialStruct(events, params, wheel, licks)


trial = struct;
for itrial = 1:numel(events.trial.sontimes) % completed trials...
    trial(itrial).onTime = events.trial.sontimes(itrial);
    trial(itrial).stimMoveTime = events.trial.movetimes(itrial) -  trial(itrial).onTime;
    trial(itrial).stimOffTime = events.trial.sofftimes(itrial) - trial(itrial).onTime;
    [~, paramIdx] = findNextEvent(params.eTime, trial(itrial).onTime);
    trial(itrial).velXL = params.velXLeft(paramIdx);
    trial(itrial).velXR = params.velXRight(paramIdx);
    trial(itrial).response = params.response(paramIdx);
    trial(itrial).rewardtime = [];
    
    % get tria block type, response window properties from event intervals
    
    trial(itrial).block = events.blocks.tags(events.trial.sonidx(itrial)>...
        events.blocks.intervals(:,1) & events.trial.sonidx(itrial)<events.blocks.intervals(:,2));
    trial(itrial).respSize = events.respWin.sizeTags(events.trial.sonidx(itrial)>...
        events.respWin.sizeIntervals(:,1) & events.trial.sonidx(itrial)<events.respWin.sizeIntervals(:,2));
    
    trial(itrial).respWinOpen = [];
    trial(itrial).respWinClosed = [];
    if ~isequal(trial(itrial).block,'passive')
        [~,~,~,trial(itrial).respWinOpen] = findNextEvent(events.trial.respOpentimes, trial(itrial).onTime);
        [~,~,~,trial(itrial).respWinClosed] = findNextEvent(events.trial.respClosetimes, trial(itrial).onTime);
        
    end
    
    % response == 1 i left, response == 2 is right
    % find next non-manual reward after stimonset if trial was rewarded
    if trial(itrial).response==1 %correct left
        [~,~,~,trial(itrial).rewardtime] =...
            findNextEvent(events.rewards.lrewardsTimes,trial(itrial).onTime);
    end
    if trial(itrial).response==2 %correct right
        [~,~,~,trial(itrial).rewardtime] =...
            findNextEvent(events.rewards.rrewardsTimes,trial(itrial).onTime);
    end
end


for itrial = 1:numel(trial)
    startTime = trial(itrial).onTime-1;
    stopTime = 7+trial(itrial).onTime+str2double(regexpi(trial(itrial).respSize, '(?<=respSize\s*)\d*', 'match')); % 1s after respWindow
    trial(itrial).licksL = licks.lickTimeL(licks.lickTimeL < stopTime & licks.lickTimeL > startTime)-trial(itrial).onTime;
    trial(itrial).licksR = licks.lickTimeR(licks.lickTimeR < stopTime & licks.lickTimeR > startTime)-trial(itrial).onTime;
    
    [~, wheelStartIdx] = min(abs(startTime-wheel.eTime));
    [~, wheelStopIdx] = min(abs(stopTime-wheel.eTime));
    trial(itrial).wheel = wheel.smthSpeed(wheelStartIdx:wheelStopIdx);
    
end
mr = events.rewards.mrrewardsTimes;
ml = events.rewards.mlrewardsTimes;
mrews = sort([mr; ml]);
for itrial = 1:numel(trial)
    [~,~,mRewAbsTime,mRewRelTime] = findNextEvent(mrews, trial(itrial).onTime);
    if (mRewAbsTime < trial(itrial).onTime+trial(itrial).respWinClosed)
        trial(itrial).manualReward = 1;
        trial(itrial).manualRewardTime = mRewRelTime;
    else
        trial(itrial).manualReward = 0;
        trial(itrial).manualRewardTime = [];
    end
    clear mRewAbsTime mRewRelTime
end

for itrial = 1:numel(trial)
    alltriallicks = sort([trial(itrial).licksL; trial(itrial).licksR]);
    % passive trials
    if isequal(trial(itrial).block, "passive")
        if any(alltriallicks > trial(itrial).respWinOpen &...
                alltriallicks < trial(itrial).rewardtime)
            trial(itrial).engaged = 1;
        else
            trial(itrial).engaged = 0;
        end
        
            %fprintf(num2str(itrial))
            %fprintf('skipping a passive trial')
        
        % not passive trials
    else
        if (trial(itrial).response ~=3 && trial(itrial).manualReward==0)
            trial(itrial).engaged = 1;
        elseif (any(alltriallicks > trial(itrial).respWinOpen &...
                alltriallicks < trial(itrial).respWinClosed)) && (trial(itrial).manualReward==0)
            trial(itrial).engaged = 1;
        else
            trial(itrial).engaged = 0;
        end
    end
end



