function [x_SAVE,y_SAVE,eb_SAVE] = eventwindowPlotFormatV2(DataAVG,Dts,varnamesDATA,setupParam,allTrials)

% Setup group info (if there are groups)
allTrialsID = allTrials.ID;

if setupParam.CompareGroups == 1
%     GroupParam = TrialParam.GroupParam;
    groupnames1 = fieldnames(allTrialsID);
    groupidx = zeros(1,numel(groupnames1));
        for i = 1:numel(groupnames1)
            if ~isempty(allTrialsID.(groupnames1{i}))
                groupidx(i) = 1;
            end
        end
    groups = groupnames1(groupidx==1);
    
%     expGroups1 =  ['A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'];
%     expGroups = expGroups1(ismember(expGroups1,groups));
    
%     refGroups1 = ['T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
%     refGroups = refGroups1(ismember(refGroups1,groups));
end

%% Setup data name parameters
All = DataAVG.all.average;
ST1 = {'Raw'; 'Recentered'; 'DecayAdj'};
inUseST = fieldnames(All);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);

%% 
x.Dts = transpose(Dts(:,1));

%% Store y data for combined trials
for t = 1:numel(ST)
    for i = 1:numel(varnamesDATA)
        tempY = DataAVG.all.average.(ST{t}).(varnamesDATA{i});
        tempEB = DataAVG.all.sem.(ST{t}).(varnamesDATA{i});
        
        y.all.(ST{t}).(varnamesDATA{i}) = transpose(tempY);
        eb.all.(ST{t}).(varnamesDATA{i}) = transpose(tempEB);
            eb.all.lo.(ST{t}).(varnamesDATA{i}) = transpose(tempY - tempEB);
            eb.all.hi.(ST{t}).(varnamesDATA{i}) = transpose(tempY + tempEB);
    end
end

        
%% Store y data by group
if setupParam.CompareGroups == 1
    for g = 1:numel(groups)
        for t = 1:numel(ST)
            for i = 1:numel(varnamesDATA)
                clear tempYgroup; clear tempEBgroup;
                tempYgroup = DataAVG.(groups{g}).average.(ST{t}).(varnamesDATA{i});
                tempEBgroup = DataAVG.(groups{g}).sem.(ST{t}).(varnamesDATA{i});
                
                y.(groups{g}).(ST{t}).(varnamesDATA{i}) = transpose(tempYgroup);
                eb.(groups{g}).(ST{t}).(varnamesDATA{i}) = transpose(tempEBgroup);
                    eb.(groups{g}).lo.(ST{t}).(varnamesDATA{i}) = transpose(tempYgroup - tempEBgroup);
                    eb.(groups{g}).hi.(ST{t}).(varnamesDATA{i}) = transpose(tempYgroup + tempEBgroup);
            end
        end
    end
end

x_SAVE = x;
y_SAVE = y;
eb_SAVE = eb;







