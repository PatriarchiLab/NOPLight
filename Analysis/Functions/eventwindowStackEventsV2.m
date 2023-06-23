function [eventwindowData_SAVE,entiresessionData_SAVE,eventwindowDts_SAVE] = eventwindowStackEventsV2(ProcessedData,Dts,varnamesDATA,setupParam,TrialParam,Fs)

%% Setup trial/data info
ST1 = {'Raw'; 'Recentered'; 'DecayAdj';};
inUseST = fieldnames(ProcessedData);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);

tempDts = Dts(:,1);
resampf = setupParam.resamplefactor;
timewindow = setupParam.timewindow;
samplerange = floor((timewindow*Fs)/resampf);
%     TWcenter = TrialParam.rawtimestamps{1}(1);
%     TWstart = TWcenter - timewindow;
%     TWend = TWcenter + timewindow;
%     
%     samplerange1 = find(tempDts<TWstart,1,'last') + 1;
%     samplerange2 = find(tempDts>TWend,1,'first');
% samplerange = length(samplerange1:samplerange2)/2; % convert the +/- range of time window to sampling frequency

%% Extract data for time window surrounding each event

for t = 1:numel(ST)
    for i = 1:numel(varnamesDATA)
        eventwindowData.(ST{t}).(varnamesDATA{i}) = [];
        for p = 1:size(ProcessedData.(ST{t}).(varnamesDATA{i}),2) % p = number of animals (sessions) total
            tempTrace = ProcessedData.(ST{t}).(varnamesDATA{i})(:,p);
            tempTimeStamps = zeros(numel(TrialParam.rawtimestamps{p}),1);
            for s = 1:numel(TrialParam.rawtimestamps{p})
                tempTimeStamps(s,1) = find(tempDts<TrialParam.rawtimestamps{p}(s),1,'last');
            end
               
            for s = 1:numel(tempTimeStamps)
                trigindex = zeros(length(tempTrace),1);
                startidx = zeros(length(tempTimeStamps),1);
                endidx = zeros(length(tempTimeStamps),1);
                startidx(s) = round(tempTimeStamps(s) - samplerange);
                endidx(s) = round(tempTimeStamps(s) + samplerange);
                trigindex(startidx(s):(endidx(s) - 1)) = 1;
                eventwindowData.(ST{t}).(varnamesDATA{i})(:,end+1) = tempTrace(trigindex==1);
            end
        end
    end
end

            
eventwindowDts_SAVE = transpose(linspace(-timewindow,timewindow,size(eventwindowData.(ST{1}).(varnamesDATA{1}),1)));            


entiresessionData_SAVE = ProcessedData;


eventwindowData_SAVE = eventwindowData;



















