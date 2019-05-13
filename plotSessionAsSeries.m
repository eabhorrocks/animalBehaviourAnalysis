%function scrollPlotHandle = plotSessionAsSeries(input_args)

% STIMULUS ON
% stim on is from stimON to stimOFF. need to find these intervals.
% find idx of stim on and stim off, find associated timestamps.
% for each interval, plot __|----|__
figure, hold on
for itrial = 1:numel(events.trial.sontimes)
    plot([events.trial.sontimes(itrial), events.trial.sontimes(itrial),events.trial.sofftimes(itrial),...
        events.trial.sofftimes(itrial)], [10.1 10.6 10.6 10.1], 'k-')
    
    mTime = events.trial.movetimes(itrial); offTime = events.trial.sofftimes(itrial);
    Lmag = abs(trial(itrial).velXL); Rmag = abs(trial(itrial).velXR);
    Lscaled = Lmag * 0.05; Rscaled = Rmag * 0.05;
    plot([mTime, mTime, offTime,offTime], [9.5 9.5+Lscaled 9.5+Lscaled 9.5], 'c-')
    plot([mTime, mTime, offTime,offTime], [9 9+Rscaled 9+Rscaled 9], 'r-')
    
    if itrial~=numel(events.trial.sontimes)
    plot([events.trial.sofftimes(itrial), events.trial.sontimes(itrial+1)], [10.1 10.1],'k-')
    plot([events.trial.sofftimes(itrial), events.trial.movetimes(itrial+1)], [9.5 9.5], 'c-')
    plot([events.trial.sofftimes(itrial), events.trial.movetimes(itrial+1)], [9 9], 'r-')
    end

end

plot([0, events.trial.sontimes(1)], [10.1 10.1],'k-')
plot([0, events.trial.movetimes(1)], [9.5 9.5], 'c-')
plot([0, events.trial.movetimes(1)], [9 9], 'r-')

% reward times
plot(events.rewards.mrrewardsTimes, 8.75*ones(size(events.rewards.mrrewardsTimes)), 'd', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k','MarkerSize', 12);
plot(events.rewards.mlrewardsTimes, 8.75*ones(size(events.rewards.mlrewardsTimes)), 'd', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k','MarkerSize', 12);

plot(events.rewards.rrewardsTimes, 8.25*ones(size(events.rewards.rrewardsTimes)), 's', 'MarkerFaceColor', 'r','MarkerEdgeColor', 'r', 'MarkerSize', 12);
plot(events.rewards.lrewardsTimes, 8.25*ones(size(events.rewards.lrewardsTimes)), 's', 'MarkerFaceColor', 'c','MarkerEdgeColor', 'c', 'MarkerSize', 12);



for il = 1:numel(licks.lickTimeL)
    plot(licks.lickTimeL(il), 7.25, 'c.', 'MarkerSize', 15)
end
for ir = 1:numel(licks.lickTimeR)
    plot(licks.lickTimeR(ir), 7, 'r.', 'MarkerSize', 15)
end

plot(wheel.eTime, 5+(wheel.smthSpeed/max(wheel.smthSpeed))*2)
plot([wheel.eTime(1), wheel.eTime(end)], [5 5], 'k-') 


a = gca; 
dx=50;

% Set appropriate axis limits and settings
set(gcf,'doublebuffer','on');
%% This avoids flickering when updating the axis
set(a,'xlim',[0 dx]);
%set(a,'ylim',[min(y) max(y)]);
% Generate constants for use in uicontrol initialization
pos=get(a,'position');
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
%% This will create a slider which is just underneath the axis
%% but still leaves room for the axis labels above the slider
xmax=max(wheel.eTime);
S=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
%% Setting up callback string to modify XLim of axis (gca)
%% based on the position of the slider (gcbo)
% Creating Uicontrol
h=uicontrol('style','slider',...
    'units','normalized','position',Newpos,...
    'callback',S,'min',0,'max',xmax-dx);