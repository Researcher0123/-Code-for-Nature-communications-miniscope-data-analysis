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
%matFilename1='D:\【new\程\T2_8bit_200_cut_result.mat';
%hf1=load(matFilename1);
%results=hf1.results;
%Cfile=hf1.results.C_raw;

%%
[numOfCell,numOf_cData]=size(Cfile);
t_stim=10;
t_baselineDuration=t_stim;%这儿定义baseline的时间
fps=20;%这儿定义帧率

for indCell=1:numOfCell    
    tempBaselineData=Cfile(indCell,1:t_baselineDuration*fps);
    meanTemp=mean(tempBaselineData);
   C_raw(indCell,:)=Cfile(indCell,:)-meanTemp;
end
xplot=(1:numOf_cData)/fps;
% %plot(xplot,C_raw) 
%%
%获取基线mean和sem
for indCell=1:numOfCell    
    tempBaselineData=C_raw(indCell,1:t_baselineDuration*fps);
    meanBaseline(indCell,1)=mean(tempBaselineData);
    semBaselineRaw(indCell,1)=std(tempBaselineData)/sqrt(length(tempBaselineData)-1);
end
%2.	计算基线并将数据归一化,数据归一化为Cdata，
%这儿已经是100*deltaF/F
%3.	筛选有反应的细胞,检测从10到40是否有反应
t_windowStart=10;
t_windowEnd=40;
windowSmooth=1;%1秒平滑
responseMark=zeros(numOfCell,1); %置零
for indCell=1:numOfCell   
    trialFromStim=C_raw(indCell,:);
    %1秒的值大于mean+4倍sem算有反应，所以平滑一秒
    tempOneSmooth=smooth(trialFromStim,fps*windowSmooth);    
    tempMax=max(tempOneSmooth(t_windowStart*fps:t_windowEnd*fps));
    if tempMax> meanBaseline(indCell,1)+4*semBaselineRaw(indCell,1)
       responseMark(indCell,1)=1;
    end
end
%4 把有反应的细胞取出来,有反应的细胞，先生成新变量，输出生成新文件
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
%t_stim=10;%10秒为开始,最后为结束,最开始已定义
threshold_peak=95;% 95%?
for indCellR=1:numOfCellResponse
    trialWhole=Cdata2(indCellR,:);
    trialFromStim=trialWhole(t_stim*fps:end); %从刺激开始到结束的数据
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
    peakDuration(indCellR,1)=indPeakEndPart-1;%峰值持续时间（单位：采样点）
    %计算最大值
    trialPart_inPeak=trialWhole(indPeakStartFromStart(indCellR,1):indPeakEndFromStart(indCellR,1));
    [peakValue,indMax]=max(trialPart_inPeak);%
    trialPart_afterMax=trialWhole(indMax+indPeakStartFromStart(indCellR,1)-1 :end);
    indHalfMaxAll= find(trialPart_afterMax<0.5*peakValue);
    if~isempty(indHalfMaxAll)
        indHalf=indHalfMaxAll(1);
        decayDuration(indCellR,1)=indHalf;
    end    
end
%有indPeakStartFromStart，indPeakEndFromStart，peakDuration, decayDuration
peakLessThan40 = ones(size(indPeakStartFromStart));%先设置1
peakLessThan40(indPeakStartFromStart>50*fps)=0; %大于40的index设置为0
 [B,indSort]=sort(indPeakStartFromStart);
 peakLessThan40Sort=peakLessThan40(indSort); %跟着排序做排序
 %CdataSort=C_raw2(indSort,:);
 CdataSort=C_raw2(indSort(peakLessThan40Sort>0),:); %
 %%
 %xlswrite('111.xls',CdataSort);
csvwrite('111.csv',CdataSort);
 
 %%
%figure;plot(xplot,Cdata2);figure;plot(xplot,CdataSort);

%5a热图
figure;
imagesc(CdataSort);
%如果上图需要加坐标，试试自己加？
box off;
set(gca,'xtick',[1 200:200:1400]);
set(gca,'xtickLabel',num2str([-10;0;10;20;30;40;50;60]))
%其他设置

%5b 文献里为峰值出现时间
peaktimeAll=indPeakStartFromStart/fps -t_stim;
binrange=0:1:60;
countn=histc(peaktimeAll,binrange);
PeakRatioOfEachBin=countn/length(peaktimeAll);
%如果保存，保存这两个值 binrange，RatioOfEachBin
figure;
plot(binrange(1:end-1),PeakRatioOfEachBin(1:end-1));

%5c 计算半衰期分布
binrange2=0:1:60;
count_decay= histc(decayDuration,binrange2); 
decayDurationOfEachBin=count_decay/length(decayDuration);
%如果保存，保存这两个值 binrange2，decayDurationOfEachBin
figure;
plot(binrange2(1:end-1),decayDurationOfEachBin(1:end-1));




