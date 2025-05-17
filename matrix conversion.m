matFilename1='F:\mini\cut\T2_8bit_200_cut_result.mat';
hf1=load(matFilename1);
results=hf1.results;
C_raw=hf1.results.C_raw';

xlsfileanme='F:\mini\cut\4.csv';

csvwrite(xlsfileanme,C_raw);