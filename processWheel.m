function [wheel] = processWheel(wheel,smoothMethod,windowSize)

idx = find(isnan(wheel.eTime));

for i = 1:numel(idx) % interpolate any NaNs in elapsed time
    wheel.eTime(idx) = (wheel.eTime(idx-1) + wheel.eTime(idx+1) ) /2;
end

halfMax = max(wheel.pos)/2;
wheel.unwrapped = unwrap(wheel.pos, halfMax);
% not sure I have the right ticks per rev.
wheel.dist = wheel2unit(wheel.unwrapped, 1024, 17.78); % pos, ticks/rev, wheel diam

% this doesnt seem right? need to do movmw
wheel.rawSpeed = diff(wheel.dist)./diff(wheel.eTime);
wheel.rawSpeed = movmean(wheel.rawSpeed, 2);
wheel.rawSpeed = [wheel.rawSpeed(1); wheel.rawSpeed];
wheel.smthSpeed = smoothdata(wheel.rawSpeed,smoothMethod,windowSize);

% wheel.acc = diff(wheel.smthSpeed)./diff(wheel.eTime);
% wheel.acc = movmean(wheel.acc, 2);
% wheel.acc = [wheel.acc(1); wheel.acc];
% wheel.smthAcc = smoothdata(wheel.acc,smoothMethod,windowSize);

%subplot(211)
%plot(wheel.eTime(1000:2000), wheel.smthSpeed(1000:2000))
% subplot(212)
% plot(wheel.eTime(1000:2000), wheel.smthAcc(1000:2000))





% wheel.speed = [wheel.speed(1); wheel.speed];
% temp_acc = diff(wheel.speed);
% wheel.acc = movmean(temp_acc, 2);
% wheel.acc = [wheel.acc(1); wheel.acc];