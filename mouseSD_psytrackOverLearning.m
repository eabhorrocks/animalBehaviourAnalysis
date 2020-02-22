%% MouseSD - Psytrack model over learning

%% List of possible inputs we may want to provide!

% - Bias
% - Speed Left
% - Speed Right
% - PrevAnswer
% - PrevChoice
% - geoMean
% - geoRatio(signed)
% - running?

%% load trials and generate psytrack inputs
tic
load('m145_alltrials.mat')

inputFile = [pwd '\m145_psyinputs.mat'];
outputFile = [pwd '\m145_psyoutput.mat'];

tempTrials = [d145trials.trials];
dayLength = [d145trials.nEngagedTrials];
dayLength(1) = dayLength(1)-1;



% stim values for left and right
vl = [tempTrials.velXL];
vr = [tempTrials.velXR];

logRatio = log([tempTrials.geoRatio]);
absSD = abs(vr)-abs(vl);

% resposne of animal: y as 1 and 2. 
y = [tempTrials.response];
y(y==1)=2; % convert right = 1 to = 2;
y(y==-1)=1; % convert left = -1 to = 1;

% prev choice as -1 and 1
choice = [tempTrials.response];
prevChoice = [NaN tempTrials.response];
prevChoice(end)=[]; prevChoice(1) = []; 

% prev answer as -1 and 1
tempans = NaN*size(vl);
leftAnswerIdx = find([tempTrials.geoRatio]<1);
rightAnswerIdx = find([tempTrials.geoRatio]>1);
tempans(leftAnswerIdx)=-1;
tempans(rightAnswerIdx)=1;
prevAns = [nan tempans];
prevAns(end) = []; prevAns(1) = [];


tempans = NaN*size(vl);
leftAnswerIdx = find([tempTrials.geoRatio]<1);
rightAnswerIdx = find([tempTrials.geoRatio]>1);
tempans(leftAnswerIdx)=1;
tempans(rightAnswerIdx)=2;
answer=tempans;

% correct is 0 for incorrect, 1 when correct
correct = zeros(size(vl));
correct([tempTrials.result]~=1)=1;


y(1) = []; vl(1) =[]; vr(1) = []; answer(1)=[]; correct(1)=[];
logRatio(1) = []; absSD(1) = [];
y=y'; vl=abs(vl'); vr=abs(vr'); answer=answer'; correct=correct'; dayLength=dayLength';
prevAns = prevAns'; prevChoice = prevChoice'; logRatio=logRatio'; absSD=absSD';
logRatio=logRatio./max(logRatio);
absSD = absSD./max(absSD);


save(inputFile,...
     'y', 'vl', 'vr', 'prevAns', 'prevChoice', 'answer', 'correct', 'logRatio', 'absSD', 'dayLength');

%
sysCommand = ['C:\Users\edward.horrocks\PycharmProjects\pTrackProject\venv\Scripts\python.exe C:\Users\edward.horrocks\PycharmProjects\pTrackProject\venv\runPsytrack_wholeSession.py -i ' char(inputFile) ' -o ' char(outputFile)];

system(sysCommand);

load(outputFile)

%
figure, hold on
load(outputFile);
varnames = sort(fieldnames(varNames));
nTrials = length(weights);

h = mseb(1:nTrials, weights, conf_ints);
lgnd = legend([h(1).mainLine h(2).mainLine h(3).mainLine h(4).mainLine], varnames{:});
lgnd.Location = 'eastoutside';



xlim([0 nTrials+1])
p = plot([0 nTrials], [0 0], 'k--');
set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

a=gca;

for iday = 1:numel(dayLength)
    cumday = cumsum(dayLength(1:iday));
    p = plot([cumday(end) cumday(end)], [a.YLim(1) a.YLim(2)], '-', 'Color', [.75 .75 .75]);
    set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
xlabel('Trial #')
ylabel('Weight')
toc
%% Calculate bias and perf fits
% sigma = 20;
% figure
% % bias
% choiceR = y;
% choiceR(choiceR==1)=0;
% choiceR(choiceR==2)=1;
% ansR = answer;
% ansR(ansR==1)=0;
% ansR(ansR==2)=1;
% 
% raw_bias = choiceR - ansR;
% smth_bias = smoothdata(raw_bias, 'gaussian', sigma);
% 
% QQQ = zeros(10001,1);
% QQQ(5000) = 1;
% QQQ = smoothdata(QQQ,'gaussian',sigma);
% bias_errorbars = sqrt(sum(QQQ.^2) .*...
%     smoothdata((raw_bias - smth_bias).^2, 'gaussian', sigma));
% 
% shadedErrorBar(1:nTrials, smth_bias, 2*bias_errorbars, 'lineProps', 'b');
% hold on
% plot(weights(1,:), 'k', 'LineWidth', 3)
% 
% %% performance
% sigma = 50;
% smth_correct = smoothdata(correct, 'gaussian', sigma);
% QQQ = zeros(10001,1);
% QQQ(5000) = 1;
% QQQ = smoothdata(QQQ,'gaussian',sigma);
% perf_errorbars = sqrt(sum(QQQ.^2) .*...
%     smoothdata((correct - smth_correct).^2, 'gaussian', sigma));
% figure
% shadedErrorBar(1:nTrials, smth_correct, 2*perf_errorbars, 'lineProps', 'r');
% 

%         bias_errorbars = np.sqrt(
%             np.sum(QQQ**2) * gaussian_filter(
%                 (raw_bias - smth_bias)**2, sigma=sigma))


