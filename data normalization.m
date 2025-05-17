[tempfile1,temppath1] = uigetfile({'*.csv';'*.xlsx';'*.mat';'*.*'},...
                          'File Selector');
  csvfilename1=fullfile(temppath1,tempfile1);  
%csvfilename1='Results(1).csv';
rowShift=1;columnShift=0;
dataRaw=csvread(csvfilename1,rowShift,columnShift);
xt=dataRaw(:,1);
dataAll=dataRaw(:,2:end);

meanAll=mean(dataAll(1:200,:),1);%ÑØ×ÅrowÆ½¾ù
dataNew=zeros(size(dataAll));
for indc=1:size(dataAll,2)
    dataNew(:,indc)=dataAll(:,indc)/meanAll(indc);
end
   xlsfilename='Results_average.csv'; 
csvwrite(xlsfilename,[xt dataNew]);
%csvwrite('0706.csv',[xt dataNew]);

