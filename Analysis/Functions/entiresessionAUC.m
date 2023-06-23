function [AUC_Table_SAVE] = entiresessionAUC(ProcessedData,setupParam,AUCParam,TrialParam,x)
%delay = TrialParam.delay;
BLperiod = setupParam.BLperiod;

%BLstart = BLperiod(1) + delay;
%BLend = BLperiod(2) + delay;

ST = AUCParam.type;

VN1 = {'signal' 'sigsubref' 'dFFentire_sig' 'dFFentire_sigsubref' 'Zentire_sig' 'Zentire_sigsubref'};

if contains(AUCParam.process,'none')
    VN2 = VN1(~contains(VN1,'Z'));
    VN_all = VN2(~contains(VN2,'dFF'));
else
    VN_all = VN1(contains(VN1,AUCParam.process));
end

if contains(AUCParam.data,'sigsubref')
    VN = VN_all(contains(VN_all,'sigsubref'));
else
    VN = VN_all(~contains(VN_all,'sigsubref'));
end

eventtime = TrialParam.rawtimestamps{1}(1);
%sessionlength = TrialParam.sessionlength(1);
%eventduration = TrialParam.eventduration;

%% Calculate AUC of BL period and end of session that is same length as BL period

Dts = transpose(x.Dts);


BLstart = find(Dts < BLperiod(1),1,'last') + 1;
BLend = find(Dts > BLperiod(2),1,'first') - 1;



ENDstart = length(Dts) - (BLstart + BLend);
ENDend = length(Dts);
    
BL_x = Dts(BLstart:BLend);
BL_y = ProcessedData.(ST{1}).(VN{1})(BLstart:BLend,:);
BL_AUC = zeros(1,size(BL_y,2));
    for k = 1:size(BL_y,2)
        BL_yTEMP = BL_y(:,k);
        BL_AUC(k) = trapz(BL_x,BL_yTEMP);
    end

END_x = Dts(ENDstart:ENDend);
END_y = ProcessedData.(ST{1}).(VN{1})(ENDstart:ENDend,:);  
END_AUC = zeros(1,size(END_y,2));
    for k = 1:size(END_y,2)
        END_yTEMP = END_y(:,k);
        END_AUC(k) = trapz(END_x,END_yTEMP);
    end


%% Calculate AUC from event to end of session

EVENTPeriod = (floor(eventtime/60) + 1) * 60;
    EVENTstart = find(Dts < EVENTPeriod,1,'last') + 1;
    EVENTend = length(Dts);
    
EVENT_x = Dts(EVENTstart:EVENTend);
EVENT_y = ProcessedData.(ST{1}).(VN{1})(EVENTstart:EVENTend,:);  
EVENT_AUC = zeros(1,size(EVENT_y,2));
    for k = 1:size(EVENT_y,2)
        EVENT_yTEMP = EVENT_y(:,k);
        EVENT_AUC(k) = trapz(EVENT_x,EVENT_yTEMP);
    end
    
%% Save final AUC table as struct
    
AUC_Table.BL_AUC = BL_AUC;
AUC_Table.END_AUC = END_AUC;
AUC_Table.EVENT_AUC = EVENT_AUC;

AUC_Table_SAVE = AUC_Table;








