function [reference_SAVE,sigsubref_SAVE] = scaleRefToSig_postDecayV4(Dts,DecayAdjData,setupParam,delay,allTrials)

a = allTrials.Grouped;
k = 1:numel(a);
allTrialsID = allTrials.ID;

BLperiod = setupParam.BLperiod;
    BLstart(k) = BLperiod(1) + delay(k);
    BLend(k) = BLperiod(2) + delay(k);
        BLidx1 = zeros(1,length(BLstart)); BLidx2 = zeros(1,length(BLstart));
        
if setupParam.scaleref_BLper == 1
    for d = 1:size(BLstart,2)
        tempCol = Dts(:,d);
        BLidx1(d) = find(tempCol<BLstart(d),1,'last') + 1;
        BLidx2(d) = find(tempCol>BLend(d),1,'first') - 1;
    end
else
    for d = 1:size(BLstart,2)
        tempCol = Dts(:,d);
        BLidx1(d) = 1;
        BLidx2(d) = length(tempCol);
    end
end

%% Scale each reference trace to corresponding signal trace

  % Create empty arrays to populate scaled traces into
    scaledFunction = cell(1,size(Dts,2));
    scaledRef = zeros(size(Dts,1),size(Dts,2));
    scaledSigSubRef = zeros(size(Dts,1),size(Dts,2));
    
     % Calculate linear least squares fit of within session reference to signal
     for p = 1:size(Dts,2)
         tempRef = DecayAdjData.reference(:,p);
         tempSig = DecayAdjData.signal(:,p);
         
         %scaledFunction{p} = polyfit(tempRef, tempSig, 1);
         scaledFunction{p} = polyfit(tempRef(BLidx1(p):BLidx2(p)), tempSig(BLidx1(p):BLidx2(p)), 1);
         
         scaledRef(:,p) = scaledFunction{p}(1) .*tempRef + scaledFunction{p}(2);
         scaledSigSubRef(:,p) = tempSig - scaledRef(:,p);
     end
    
    
   %% Plot
if setupParam.PlotIndividual == 0
    if setupParam.CompareGroups == 1
        groupnames1 = fieldnames(allTrialsID);
        groupidx = zeros(1,numel(groupnames1));
            for i = 1:numel(groupnames1)
                if ~isempty(allTrialsID.(groupnames1{i}))
                    groupidx(i) = 1;
                end
            end
        groups = groupnames1(groupidx==1);
        groups(contains(groups,'R')) = [];
        groups_members = zeros(1,numel(groups));
            for i = 1:numel(groups)
                groups_members(i) = numel(allTrialsID.(groups{i}));
            end
        largestgroup = max(groups_members);

            figure(5000) 
            numrow = numel(groups);
            numcol = largestgroup;
            p = 1;
            for g = 1:numel(groups)
                for s = 1:numel(allTrialsID.(groups{g}))
                    spSpot = ((g-1).*numcol) + s;
                    subplot(numrow,numcol,spSpot)

                    tempDts = Dts(:,p);
                    tempRef = DecayAdjData.reference(:,p);
                    tempSig = DecayAdjData.signal(:,p);
                    tempSigSubRef = tempSig - tempRef;

                    plot(tempDts,tempSig,'Color','#4DBEEE')
                    hold on
                    plot(tempDts,tempRef,'Color','#7E2F8E')
                    plot(tempDts,tempSigSubRef,'Color','#77AC30')

                    plot(tempDts,scaledRef(:,p),'Color','#921BEE')
                    plot(tempDts,scaledSigSubRef(:,p),'Color','g')
                        title('Scaling reference to signal')
                        xlabel('Time (s)')
                        ylabel('Raw F')
                    p = p+1;
                end
            end
            legend('raw signal', 'raw ref', 'raw sig - ref', 'scaled ref', 'sig - scaled ref')
    else
        figure(5000)
         numrow = 2;
         numcol = round(size(allTrials.Grouped,2)/2);
         for s = 1:size(allTrials.Grouped,2)
            subplot(numrow,numcol,s)
            for p = 1:size(Dts,2)
                tempDts = Dts(:,p);
                tempRef = DecayAdjData.reference(:,p);
                tempSig = DecayAdjData.signal(:,p);
                tempSigSubRef = tempSig - tempRef;

                plot(tempDts,tempSig,'Color','#4DBEEE')
                hold on
                plot(tempDts,tempRef,'Color','#7E2F8E')
                plot(tempDts,tempSigSubRef,'Color','#77AC30')

                plot(tempDts,scaledRef(:,p),'Color','#921BEE')
                plot(tempDts,scaledSigSubRef(:,p),'Color','g')

                    title('Scaling reference to signal')
                    xlabel('Time (s)')
                    ylabel('Raw F')
            end
        end
    end
    legend('raw signal', 'raw ref', 'raw sig - ref', 'scaled ref', 'sig - scaled ref')
    sname = 'CarrieCustom';
    S = hgexport('readstyle',sname);
    hgexport(gcf,'file_name',S,'applystyle',true);
    
elseif setupParam.PlotIndividual == 1
    for p = 1:size(Dts,2)
        figure(5000 + p)

        tempDts = Dts(:,p);
        tempRef = DecayAdjData.reference(:,p);
        tempSig = DecayAdjData.signal(:,p);
        tempSigSubRef = tempSig - tempRef;

        plot(tempDts,tempSig,'Color','#4DBEEE')
        hold on
        plot(tempDts,tempRef,'Color','#7E2F8E')
        plot(tempDts,tempSigSubRef,'Color','#77AC30')

        plot(tempDts,scaledRef(:,p),'Color','#921BEE')
        plot(tempDts,scaledSigSubRef(:,p),'Color','g')

            title('Scaling reference to signal')
            xlabel('Time (s)')
            ylabel('Raw F')
            legend('raw signal', 'raw ref', 'raw sig - ref', 'scaled ref', 'sig - scaled ref')
        
        sname = 'CarrieCustom';
        S = hgexport('readstyle',sname);
        hgexport(gcf,'file_name',S,'applystyle',true);
    end
end

 %%
reference_SAVE = scaledRef;
sigsubref_SAVE = scaledSigSubRef;
    
    
    
    
    
    
    