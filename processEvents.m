function [events, licks] = processEvents(events, licks, blockTags)

% deal with weird bonsai issue where stimON might be logged but trial not
% complete
todel = [];
for i=1:numel(events.tags)
    if strcmp(events.tags(i), "stimON")
        if any(strcmp(events.tags(i+1), blockTags))
            todel = [todel, i];
        end
    end
end

events.tags(todel) = [];

events.trial.sonidx = find(events.tags=="stimON");
events.trial.moveidx = find(events.tags=="dotsMOVE");
events.trial.soffidx = find(events.tags=="stimOFF");
events.trial.respOpenidx = find(events.tags=="respOPEN");
events.trial.respCloseidx = find(events.tags=="respCLOSED");
% check for incomplete trials and delete tags from them
if numel(events.trial.soffidx) < numel(events.trial.sonidx)
     events.trial.sonidx = events.trial.sonidx(1:numel(events.trial.soffidx));
     events.trial.moveidx = events.trial.moveidx(1:numel(events.trial.soffidx));
     events.trial.soffidx = events.trial.soffidx(1:numel(events.trial.soffidx));
end



events.trial.sontimes = events.eTime(events.trial.sonidx); 
events.trial.movetimes = events.eTime(events.trial.moveidx);
events.trial.sofftimes = events.eTime(events.trial.soffidx);
events.trial.respOpentimes = events.eTime(events.trial.respOpenidx);
events.trial.respClosetimes = events.eTime(events.trial.respCloseidx);

% get reward times using regexp, invariant to the valve opening times.
events = getRewardTimes(events);

% get times of left and right licks
leftidx = 1 + find(diff(licks.leftLicks)==1);
rightidx = 1 + find(diff(licks.rightLicks)==1);
licks.lickTimeL =  licks.eTime(leftidx);
licks.lickTimeR =  licks.eTime(rightidx);

% get event.tag indexes for trial type changes
[events.blocks.intervals, events.blocks.tags, events.blocks.starts] =...
    findIntervals(events.tags, blockTags, 'matches');

% get event.tag indexes for respDelay and respSize value changes
% this version could do with some error checking with diff input args
tags = {'respDelay'};

[events.respWin.delayIntervals, events.respWin.delayTags, ~] =...
    findIntervals(events.tags, tags, 'contains');

tags = {'respSize'};
[events.respWin.sizeIntervals, events.respWin.sizeTags, ~] =...
    findIntervals(events.tags, tags, 'contains');
