function eventwindowPhotomPlot_LoneFigV2(x,y,eb,setupParam,TrialParam,allTrials,ProcessedEventWindowData,loneFigure)

allTrialsID = allTrials.ID;

if setupParam.CompareGroups == 1
    GroupParam = TrialParam.GroupParam;
    groupnames1 = fieldnames(allTrialsID);
    groupidx = zeros(1,numel(groupnames1));
        for i = 1:numel(groupnames1)
            if ~isempty(allTrialsID.(groupnames1{i}))
                groupidx(i) = 1;
            end
        end
    groups = groupnames1(groupidx==1);
    
    expGroups1 =  ['A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'];
    expGroups = expGroups1(ismember(expGroups1,groups));
    
    numexpAnimals1 = zeros(1,numel(expGroups));
    for d = 1:numel(expGroups)
        numexpAnimals1(d) = numel(allTrialsID.(expGroups(d)));
    end
    numexpAnimals = sum(numexpAnimals1);
        expidx1 = TrialParam.eventindex(1,1);
        expidx2 = TrialParam.eventindex(2,numexpAnimals);
        anidx1 = TrialParam.animalindex(1);
        anidx2 = TrialParam.animalindex(numexpAnimals);
    
    refGroups1 = ['T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
    plotgroups = groups(~ismember(groups,refGroups1));
    
    legendID1 = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'};
    legID = legendID1(find(ismember(expGroups1,plotgroups))); %#ok<FNDSB>
    numgroups = numel(plotgroups);
%     refGroups = refGroups1(ismember(refGroups1,groups));
else
    numgroups = 0;
    expidx1 = TrialParam.eventindex(1,1);
    expidx2 = TrialParam.eventindex(2,end);
    anidx1 = TrialParam.animalindex(1);
    anidx2 = TrialParam.animalindex(end);
    numexpAnimals = numel(allTrialsID.A);
end

%% Setup data name/timing parameters
ST = loneFigure.type;

VN1 = {'signal' 'sigsubref' 'dFFentire_sig' 'dFFentire_sigsubref' 'Zentire_sig' 'Zentire_sigsubref' 'dFFbytrial_sig' 'dFFbytrial_sigsubref' 'Zbytrial_sig' 'Zbytrial_sigsubref'};


if contains(loneFigure.data,'none')
    VN2 = VN1(~contains(VN1,'Z'));
    VN = VN2(~contains(VN2,'dFF'));
else
    VN = VN1(contains(VN1,loneFigure.data));
end

eventtime = 0;
eventduration = TrialParam.eventduration(1);
timewindow = setupParam.timewindow;

% setup x limits
xl = [0 0];
if setupParam.viewtimewindow == 1
    xl(1) = -setupParam.viewtimewindowVal;
    xl(2) = setupParam.viewtimewindowVal;
else
    xl(1) = -timewindow;
    xl(2) = timewindow;
end

%% Setup plot coloring parameters

[choosecolor] = photomplotColor(setupParam,numgroups);

%% Plot individual figure (combined)

tempX = x.Dts;

if setupParam.CompareGroups == 0 || setupParam.CombineGroups == 1
    figure(loneFigure.fignum)
    for t = 1:numel(ST)
        numrow = 2;
        numcol = numel(VN);
        for i = 1:numel(VN)
            spSpot = i;
            subplot(numrow,numcol,spSpot)
            
            hold off
            [currenttitle] = photomplotTitle(ST(t),VN(i));
            
            tempY = y.all.(ST{t}).(VN{i});
            tempEBlo = eb.all.lo.(ST{t}).(VN{i});
            tempEBhi = eb.all.hi.(ST{t}).(VN{i});
            
            plot(tempX,tempY,'Color',string(choosecolor(2)),'LineWidth',2)
            hold on
                filledEBtemp = patch([tempX fliplr(tempX)],[tempEBlo fliplr(tempEBhi)],'k');
                alpha(filledEBtemp,0.2)
                filledEBtemp.EdgeAlpha = 0;
                set(filledEBtemp,'edgecolor',string(choosecolor(2)),'facecolor',string(choosecolor(2)))

            xlim(xl)
            yl = ylim;
            tempYL = ((floor(yl(1)) - 1):(round(yl(2)) + 1));
                if any(ismember((tempYL),0))
                    line([tempX(1) tempX(end)], [0 0],'Color','k');
                end

            line([eventtime eventtime],[yl(1) yl(2)],'Color','k');
            line([(eventtime + eventduration) (eventtime + eventduration)],[yl(1) yl(2)],'Color','k');
            ylim(yl)

            ylabel(sprintf('%s',currenttitle.Yaxis));
            xlabel('Time (s)')
            title(sprintf('Combined %s %s %s',currenttitle.ST, currenttitle.Calc,currenttitle.Data))
        end
        
        % plot heat map
            for i = 1:numel(VN)
                hmSpot = (numcol + i);
                subplot(numrow,numcol,hmSpot)
                
                
               
                [currenttitle] = photomplotTitle(ST(1),VN(i));

                tempHM = transpose(ProcessedEventWindowData.DecayAdj.(VN{i})(:,expidx1:expidx2));
                    imagesc(tempX,1:size(tempHM,1),tempHM,yl)
                    hold on
                    cb = colorbar;
                    title(cb,currenttitle.Yaxis)
                    L2 = line([0 0], [0 size(tempHM,1)+1]);
                    set(L2,'Color','white','LineWidth',3)

                    for p = 1:numexpAnimals
                        hmYlim = TrialParam.eventindex(2,p);
                        L = line([-timewindow timewindow], [hmYlim+0.5 hmYlim+0.5]);
                        set(L,'Color','white','LineWidth',3)
                    end

                    tickpts1 = TrialParam.eventindex(:,anidx1:anidx2);
                    tickpts = zeros(1,size(tickpts1,2));
                    ticklab1 = zeros(1,size(tickpts1,2));
                    for s = 1:size(tickpts1,2)
                        tickpts(s) = tickpts1(2,s) - ((tickpts1(2,s) - tickpts1(1,s))./2);
                        ticklab1(s) = TrialParam.animalindex(s);
                        ticklab{s} = append('Animal ',num2str(ticklab1(s))); %#ok<AGROW>
                    end

                xlim(xl)
                set(gca,'ytick',tickpts,'yticklabel',ticklab)
                title(sprintf('Heat Map: %s %s',currenttitle.ST,currenttitle.Data))
            end
                
                
        sname = 'CarrieCustom';
        S = hgexport('readstyle',sname);
        hgexport(gcf,'file_name',S,'applystyle',true);
    end
end

%% Plot by group

if setupParam.CompareGroups == 1
    figure(loneFigure.fignum + 1)
    for t = 1:numel(ST)
        numrow = 2;
        numcol = 2*numgroups;
        for i = 1:numel(VN)
            spSpot = (1:numgroups) + numgroups*(i-1);
            subplot(numrow,numcol,spSpot)
            hold off
            [currenttitle] = photomplotTitle(ST(t),VN(i));
            
            leg = zeros(1,numel(plotgroups));
            for g = 1:numel(plotgroups)
                tempY = y.(plotgroups{g}).(ST{t}).(VN{i});
                tempEBlo = eb.(plotgroups{g}).lo.(ST{t}).(VN{i});
                tempEBhi = eb.(plotgroups{g}).hi.(ST{t}).(VN{i});

                leg(g) = plot(tempX,tempY,'Color',string(choosecolor(g)),'LineWidth',2);
                hold on
                    filledEBtemp = patch([tempX fliplr(tempX)],[tempEBlo fliplr(tempEBhi)],'k');
                    alpha(filledEBtemp,0.2)
                    filledEBtemp.EdgeAlpha = 0;
                    set(filledEBtemp,'edgecolor',string(choosecolor(g)),'facecolor',string(choosecolor(g)))
            end

            xlim(xl)
            yl = ylim;
            tempYL = ((floor(yl(1)) - 1):(round(yl(2)) + 1));
                if any(ismember((tempYL),0))
                    line([tempX(1) tempX(end)], [0 0],'Color','k');
                end

            line([eventtime eventtime],[yl(1) yl(2)],'Color','k');
            line([(eventtime + eventduration) (eventtime + eventduration)],[yl(1) yl(2)],'Color','k');
            ylim(yl)

            ylabel(sprintf('%s',currenttitle.Yaxis));
            xlabel('Time (s)')
            title(sprintf('Combined %s %s %s',currenttitle.ST, currenttitle.Calc,currenttitle.Data))
            legend(leg,legID)
        end
        
        for i = 1:numel(VN)
            for g = 1:numel(plotgroups)
                hmSpot = numcol + numgroups*(i-1) + g;
                subplot(numrow,numcol,hmSpot)
                
                group_expidx1 = GroupParam.(plotgroups{g}).eventindex(1,1);
                group_expidx2 = GroupParam.(plotgroups{g}).eventindex(2,end);
                
                [currenttitle] = photomplotTitle(ST(1),VN(i));

                    tempHM = transpose(ProcessedEventWindowData.DecayAdj.(VN{i})(:,group_expidx1:group_expidx2));
                    imagesc(tempX,1:size(tempHM,1),tempHM,yl)
                    hold on
                    cb = colorbar;
                    title(cb,currenttitle.Yaxis)
                    L2 = line([0 0], [0 size(tempHM,1)+1]);
                    set(L2,'Color','white','LineWidth',3)
                    
                    hmYlimALL = GroupParam.(plotgroups{g}).eventindex;
                    for p = 1:numel(GroupParam.(plotgroups{g}).animalindex)
                        hmYlimTEMP = hmYlimALL(2,p);
                        hmYlim = hmYlimTEMP - hmYlimALL(1,1) + 1;
                        L = line([-timewindow timewindow], [hmYlim+0.5 hmYlim+0.5]);
                        set(L,'Color','white','LineWidth',3)
                    end
                    
                  
                    tickpts2 = GroupParam.(plotgroups{g}).eventindex;
                    tickpts1 = tickpts2 - tickpts2(1,1) + 1;
                    tickpts = zeros(1,size(tickpts1,2));
                    ticklab1 = zeros(1,size(tickpts1,2));
                    for s = 1:size(tickpts1,2)
                        tickpts(s) = tickpts1(2,s) - ((tickpts1(2,s) - tickpts1(1,s))./2);
                        ticklab1(s) = TrialParam.animalindex(s);
                        ticklab{s} = append('Animal ',num2str(ticklab1(s))); 
                    end

                xlim(xl)
                set(gca,'ytick',tickpts,'yticklabel',ticklab)
                title(sprintf('Heat Map Group %s',plotgroups{g}))
            end
        end
    end
end

                
            
   
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            







