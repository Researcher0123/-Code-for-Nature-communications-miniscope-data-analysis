filenamelist{1}='Footshock.mat';
%filenamelist{2}='M22_BattleBot.mat';
%filenamelist{3}='M24_BattleBot.mat';
%filenamelist{4}='M25_BattleBot.mat';
%filenamelist{5}='YM78_BattleBot.mat';
%filenamelist{6}='M58_BattleBot_T1_F_8bit_200_CUT_result.mat';
%filenamelist{7}='M69_BattleBot_T1_8bit_200_cut_result.mat';
%filenamelist{8}='M54_BattleBot_T1_8bit_200_cut_2_result.mat';

%filenamelist{1}='M21_footshock.mat';
%filenamelist{2}='M22_footshock.mat';
%filenamelist{3}='M24_footshock_2.mat';
%filenamelist{4}='M25_footshock.mat';
%filenamelist{5}='M78_footshock.mat';
%filenamelist{6}='M54_footshock_T13_8bit_200_cut_result_2.mat';
%filenamelist{7}='M58_footshock_T13_F_8bit_200_cut_result.mat';
%filenamelist{8}='M69_footshock_T16_8bit_200_cut_result_2.mat';

Cfile=[];
for indf=1:1%length(filenamelist)
    matFilename1=filenamelist{indf};
hf1=load(matFilename1);
results=hf1.results;
CfileAdd=hf1.results.C_raw;
Cfile=[Cfile;CfileAdd];
end

%%
%matFilename1='D:\��new\��\T2_8bit_200_cut_result.mat';
%hf1=load(matFilename1);
%results=hf1.results;
%Cfile=hf1.results.C_raw;

%%
[numOfCell,numOf_cData]=size(Cfile);
t_stim=10;
t_baselineDuration=t_stim;%�������baseline��ʱ��
fps=20;%�������֡��

for indCell=1:numOfCell    
    tempBaselineData=Cfile(indCell,1:t_baselineDuration*fps);
    meanTemp=mean(tempBaselineData);
   C_raw(indCell,:)=Cfile(indCell,:)-meanTemp;
end
xplot=(1:numOf_cData)/fps;
% %plot(xplot,C_raw) 
%%
%��ȡ����mean��sem
for indCell=1:numOfCell    
    tempBaselineData=C_raw(indCell,1:t_baselineDuration*fps);
    meanBaseline(indCell,1)=mean(tempBaselineData);
    semBaselineRaw(indCell,1)=std(tempBaselineData)/sqrt(length(tempBaselineData)-1);
end
%2.	������߲������ݹ�һ��,���ݹ�һ��ΪCdata��
%����Ѿ���100*deltaF/F
%3.	ɸѡ�з�Ӧ��ϸ��,����10��40�Ƿ��з�Ӧ
t_windowStart=10;
t_windowEnd=40;
windowSmooth=1;%1��ƽ��
responseMark=zeros(numOfCell,1); %����
for indCell=1:numOfCell   
    trialFromStim=C_raw(indCell,:);
    %1���ֵ����mean+4��sem���з�Ӧ������ƽ��һ��
    tempOneSmooth=smooth(trialFromStim,fps*windowSmooth);    
    tempMax=max(tempOneSmooth(t_windowStart*fps:t_windowEnd*fps));
    if tempMax> meanBaseline(indCell,1)+4*semBaselineRaw(indCell,1)
       responseMark(indCell,1)=1;
    end
end
%4 ���з�Ӧ��ϸ��ȡ����,�з�Ӧ��ϸ�����������±���������������ļ�
C_raw2=C_raw(responseMark==1,:);
meanBaseline2=meanBaseline(responseMark==1,:);
semBaselineRaw2=semBaselineRaw(responseMark==1,:);
semBaseline2=semBaselineRaw(responseMark==2,:);
%clear C_raw  Cdata  meanBaseline semBaselineRaw semBaseline;
[numOfCellResponse,numOf_cData2]=size(C_raw2);
Cdata2=zeros(size(C_raw2));
for indCellR=1:numOfCellResponse
  tempmaxtrial=max(C_raw2(indCellR,:));
  Cdata2(indCellR,:)=C_raw2(indCellR,:)*100/tempmaxtrial;
end
%plot(xplot,C_raw2) 
%
%t_stim=10;%10��Ϊ��ʼ,���Ϊ����,�ʼ�Ѷ���
threshold_peak=95;% 95%?
for indCellR=1:numOfCellResponse
    trialWhole=Cdata2(indCellR,:);
    trialFromStim=trialWhole(t_stim*fps:end); %�Ӵ̼���ʼ������������
    indtemp1=find(trialFromStim>threshold_peak);
    if ~isempty(indtemp1)
        indPeakStart=indtemp1(1);
    else
        indPeakStartFromStart(indCellR,1)=-1;
        indPeakEndFromStart(indCellR,1)=-1;
        indPeakStartFromStart(indCellR,1)=-1;
        decayDuration(indCellR,1)=-1;
        duration(indCellR,1)=-1;
        continue;
    end
    trialpart_AfterPeakStart=trialFromStim(indPeakStart:end);
    indtemp2=find(trialpart_AfterPeakStart<threshold_peak);
    if ~isempty(indtemp2)
        indPeakEndPart=indtemp2(1);
    else
        indPeakEndPart=length(trialpart_AfterPeakStart);
        warning('peak last too long!');
    end    
    indPeakEnd=indPeakEndPart + indPeakStart-1;
    indPeakStartFromStart(indCellR,1)=indPeakStart + t_stim*fps-1;
    indPeakEndFromStart(indCellR,1)=indPeakEnd + t_stim*fps-1;
    peakDuration(indCellR,1)=indPeakEndPart-1;%��ֵ����ʱ�䣨��λ�������㣩
    %�������ֵ
    trialPart_inPeak=trialWhole(indPeakStartFromStart(indCellR,1):indPeakEndFromStart(indCellR,1));
    [peakValue,indMax]=max(trialPart_inPeak);%
    trialPart_afterMax=trialWhole(indMax+indPeakStartFromStart(indCellR,1)-1 :end);
    indHalfMaxAll= find(trialPart_afterMax<0.5*peakValue);
    if~isempty(indHalfMaxAll)
        indHalf=indHalfMaxAll(1);
        decayDuration(indCellR,1)=indHalf;
    end    
end
%��indPeakStartFromStart��indPeakEndFromStart��peakDuration, decayDuration
peakLessThan40 = ones(size(indPeakStartFromStart));%������1
peakLessThan40(indPeakStartFromStart>50*fps)=0; %����40��index����Ϊ0
 [B,indSort]=sort(indPeakStartFromStart);
 peakLessThan40Sort=peakLessThan40(indSort); %��������������
 %CdataSort=C_raw2(indSort,:);
 CdataSort=C_raw2(indSort(peakLessThan40Sort>0),:); %
 %%
 %xlswrite('111.xls',CdataSort);
csvwrite('111.csv',CdataSort);
 
 %%
%figure;plot(xplot,Cdata2);figure;plot(xplot,CdataSort);

%5a��ͼ
figure;
imagesc(CdataSort);
%�����ͼ��Ҫ�����꣬�����Լ��ӣ�
box off;
set(gca,'xtick',[1 200:200:1400]);
set(gca,'xtickLabel',num2str([-10;0;10;20;30;40;50;60]))
%��������

%5b ������Ϊ��ֵ����ʱ��
peaktimeAll=indPeakStartFromStart/fps -t_stim;
binrange=0:1:60;
countn=histc(peaktimeAll,binrange);
PeakRatioOfEachBin=countn/length(peaktimeAll);
%������棬����������ֵ binrange��RatioOfEachBin
figure;
plot(binrange(1:end-1),PeakRatioOfEachBin(1:end-1));

%5c �����˥�ڷֲ�
binrange2=0:1:60;
count_decay= histc(decayDuration,binrange2); 
decayDurationOfEachBin=count_decay/length(decayDuration);
%������棬����������ֵ binrange2��decayDurationOfEachBin
figure;
plot(binrange2(1:end-1),decayDurationOfEachBin(1:end-1));




