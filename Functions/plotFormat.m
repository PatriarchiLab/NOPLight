function [x,y,eb,mini,maxi] = plotFormat(timewindowAVG,varnamesENTIRE,setupParam)
All = timewindowAVG.all.average;
VN = varnamesENTIRE;

timewindow = setupParam.timewindow;
BLperiod = setupParam.BLperiod;

ST1 = {'Raw'; 'Recentered'; 'DecayAdj'; 'RefDecayAdjExp'; 'RefDecayAdjPoly'};
inUseST = fieldnames(All);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);

J1 = ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'R'];
if setupParam.CompareGroups == 1
    numgroups1 = fieldnames(timewindowAVG);
    numgroups = cell2mat(numgroups1(2:end));
    J = J1(ismember(J1,numgroups));
end


% J1 = ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'];
% ST = {'Raw', 'Recentered', 'DecayAdj'};
% VN = varnamesENTIRE;
% timewindow = setupParam.timewindow;
% BLperiod = setupParam.BLperiod;
% 
% if setupParam.CompareGroups == 1
%     numgroups1 = fieldnames(timewindowAVG);
%     numgroups = 1:(size(numgroups1,1) - 1);
% 
%     J = J1(1:numel(numgroups));
% end


%% Store in plot format

x.Dts = linspace(-timewindow,timewindow,length(timewindowAVG.all.average.(string(ST(1))).(string(VN(1)))));
BLstart = find(x.Dts<(BLperiod(1)),1,'last') + 1;

%%
for t = 1:numel(ST)
    for i = 1:numel(VN)
        tempY = timewindowAVG.all.average.(string(ST(t))).(string(VN(i)));
        tempEB =  timewindowAVG.all.sem.(string(ST(t))).(string(VN(i)));
        y.all.(string(ST(t))).(string(VN(i))) = transpose(tempY);
        eb.all.(string(ST(t))).(string(VN(i))) = transpose(tempEB);
            eb.all.lo.(string(ST(t))).(string(VN(i))) = transpose(tempY - tempEB);
            eb.all.hi.(string(ST(t))).(string(VN(i))) = transpose(tempY + tempEB);
        
        
        mini.all.(string(ST(t))).(string(VN(i))) = min(tempY(BLstart:end));
        maxi.all.(string(ST(t))).(string(VN(i))) = max(tempY(BLstart:end));
    end
end


%% Store groups in plot format

if setupParam.CompareGroups == 1
    for g = 1:numel(J)
        for t = 1:numel(ST)
            for i = 1:numel(VN)
                tempYgroup = timewindowAVG.(J(g)).average.(string(ST(t))).(string(VN(i)));
                tempEBgroup = timewindowAVG.(J(g)).sem.(string(ST(t))).(string(VN(i)));
                y.(J(g)).(string(ST(t))).(string(VN(i))) = transpose(tempYgroup);
                eb.(J(g)).(string(ST(t))).(string(VN(i))) = transpose(tempEBgroup);
                    eb.(J(g)).lo.(string(ST(t))).(string(VN(i))) = transpose(tempYgroup - tempEBgroup);
                    eb.(J(g)).hi.(string(ST(t))).(string(VN(i))) = transpose(tempYgroup + tempEBgroup);
                    
                mini.(J(g)).(string(ST(t))).(string(VN(i))) = min(tempYgroup(BLstart:end));
                maxi.(J(g)).(string(ST(t))).(string(VN(i))) = max(tempYgroup(BLstart:end));
            end
        end
    end
end

                    
        
        
        
        
        
