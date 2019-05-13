function [latency, index, absoluteTime, relativeTime] = findNextEvent(vectorOfTimes, eventTime)
temp = vectorOfTimes-eventTime;
temp(temp<0) = NaN;
[latency, index] = min(abs(temp));
absoluteTime = vectorOfTimes(index);
relativeTime = absoluteTime-eventTime;