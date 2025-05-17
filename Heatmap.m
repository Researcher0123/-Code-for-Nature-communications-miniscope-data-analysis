clear;
[zzfilename1,zzpathname1,~]=uigetfile(...
                     { '*.*','All Flies(*.*)';...  
                     '*.xlsx','xlsx file(*.xlsx)';...                                                           
                     },...
                     'Pick a file');
if zzfilename1~=0                 
xlsfilename=fullfile(zzpathname1,zzfilename1);
end     
%%
data1V=xlsread(xlsfilename);%type1 visual sti
dataM=data1V(2:end,2:end);
xt=data1V(2:end,1);
figure;set(gcf,'position',[248 332 1200 400]);
box off;
dataAll1=dataM';
hImg1=imagesc(dataAll1,[-3 10]);
xtick =[0 300 600 900 1200];  %是按照第多少个数据来赋值，如100帧的数据1s对应100
xlim([0 1300]);  %从0开始，而不是从负值开始，右边为总时宽的数据个数，而非最大时间
 xticklablel =[-3 0 3 6 9];
set(gca,'tickdir','out');
set(gca,'Xtick',xtick,'XTickLabel',xticklablel,'fontsize',24);
xlabel('Time (s)','fontsize',24);
 ytick = [1 2 3 4 5 6 7 8 9 10 11 12];
 yticklablel=[1 2 3 4 5 6 7 8 9 10 11 12];   %ytick; 
set(gca,'Ytick',ytick,'YTickLabel',yticklablel); 
ylabel('Trials');  %zzfilename1(1:end-4));
box off;
%colorbar();
colormap(jet);
colorbar('Ticks',[0,2,4,6,8,10],'TickLabels',{'0','2','4','6','8','10'});

set(gca,'ticklength',[0 0])