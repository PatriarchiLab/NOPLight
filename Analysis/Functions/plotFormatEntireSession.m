function [x_SAVE,y_SAVE,eb_SAVE] = plotFormatEntireSession(superStackAVG,varnamesENTIRE,setupParam)

All = superStackAVG.all.average;
VN = varnamesENTIRE;

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
    numgroups1 = fieldnames(superStackAVG);
    numgroups = cell2mat(numgroups1(2:end));
    J = J1(ismember(J1,numgroups));
end


%% Store in plot format

x.Dts = transpose(All.(string(ST(1))).Dts);

%%
for t = 1:numel(ST)
    for i = 1:numel(VN)
        tempY = superStackAVG.all.average.(string(ST(t))).(string(VN(i)));
        tempEB =  superStackAVG.all.sem.(string(ST(t))).(string(VN(i)));
        y.all.(string(ST(t))).(string(VN(i))) = transpose(tempY);
        eb.all.(string(ST(t))).(string(VN(i))) = transpose(tempEB);
            eb.all.lo.(string(ST(t))).(string(VN(i))) = transpose(tempY - tempEB);
            eb.all.hi.(string(ST(t))).(string(VN(i))) = transpose(tempY + tempEB);
    end
end


%% Store groups in plot format

if setupParam.CompareGroups == 1
    for g = 1:numel(J)
        for t = 1:numel(ST)
            for i = 1:numel(VN)
                tempYgroup = superStackAVG.(J(g)).average.(string(ST(t))).(string(VN(i)));
                tempEBgroup = superStackAVG.(J(g)).sem.(string(ST(t))).(string(VN(i)));
                y.(J(g)).(string(ST(t))).(string(VN(i))) = transpose(tempYgroup);
                eb.(J(g)).(string(ST(t))).(string(VN(i))) = transpose(tempEBgroup);
                    eb.(J(g)).lo.(string(ST(t))).(string(VN(i))) = transpose(tempYgroup - tempEBgroup);
                    eb.(J(g)).hi.(string(ST(t))).(string(VN(i))) = transpose(tempYgroup + tempEBgroup);
            end
        end
    end
end

                    
x_SAVE = x;
y_SAVE = y;
eb_SAVE = eb;
        
        
        
        
