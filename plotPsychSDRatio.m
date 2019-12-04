function speed = plotPsychSDRatio(trials, options, options2)

activeTrials = trials(find([trials.type]=='activev2'));
meanSpeeds = unique([trials.geoMean]);
validTrials = activeTrials(find([activeTrials.engaged]==1));

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

end


options = options2;

for ispeed = 1:numel(meanSpeeds)
    for iratio = 1:numel(speed(ispeed).ratios)
        speed(ispeed).abspsigMatrix(iratio,1) = round(abs(speed(ispeed).psigMatrix(iratio,1)));
        speed(ispeed).abspsigMatrix(iratio,2) = numel(find([speed(ispeed).ratTrials(iratio).trials.result]~=0));
        speed(ispeed).abspsigMatrix(iratio,3) = numel([speed(ispeed).ratTrials(iratio).trials]);
    end
    
    
    speed(ispeed).abspsigResult = psignifit(speed(ispeed).abspsigMatrix,options);
    figure
    plotPsych(speed(ispeed).abspsigResult);
    title(['(abs) Speed: ' num2str(speed(ispeed).meanSpeed)])
end