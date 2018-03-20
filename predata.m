function [X_train,radioMap,validData,testData] = predata()
%% 文件路径
fileFM = dir('FM\*_*.bin');
fileFMtest = dir('FM\test\test*_*.bin');
% fileDTMB = dir('DTMB\*_*.bin');
% fileDTMBtest = dir('DTMB\test\test*_*.bin');
addpath FM FM\test
%% 预分配内存
X_train = zeros(400,19000,length(fileFM),'single');
X_valid = zeros(400,500  ,length(fileFM),'single');
X_test  = zeros(400,2000 ,length(fileFMtest),'single');
Y_train = zeros(2,length(fileFM));
Y_test  = zeros(2,length(fileFMtest));
%% 读取train&valid数据
for ii = 1:length(fileFM)
    fidFM   = fopen(fileFM(ii).name,'rb');
    fidDTMB = fopen(['DTMB\' fileFM(ii).name],'rb');
    fseek(fidFM ,-1.56e7,'eof');
    fseek(fidDTMB,-1.56e7,'eof');
    dataFM   = fread(fidFM , 3.8e6,'single=>single');
    dataDTMB = fread(fidDTMB,3.8e6,'single=>single');
    X_train(1:200 , :,ii) = reshape(dataFM , 200,19000);
    X_train(201:end,:,ii) = reshape(dataDTMB,200,19000);
    Y_train(:,ii) = [str2double(fileFM(ii).name(1:2)) str2double(fileFM(ii).name(4:5))];
    dataValidFM   = fread(fidFM  ,1e5,'single=>single');
    dataValidDTMB = fread(fidDTMB,1e5,'single=>single');
    X_valid(1:200 , :,ii) = reshape(dataValidFM , 200,500);
    X_valid(201:end,:,ii) = reshape(dataValidDTMB,200,500);
    fclose(fidFM);
    fclose(fidDTMB);
end
Y_valid = Y_train;
%% 读取test数据
for ii = 1:length(fileFMtest)
    fidFMtest   = fopen(fileFMtest(ii).name,'rb');
    fidDTMBtest = fopen(['DTMB\test\' fileFMtest(ii).name],'rb');
    fseek(fidFMtest , 8e4,'bof');
    fseek(fidDTMBtest,8e4,'bof');
    dataFMtest   = fread(fidFMtest , 4e5,'single=>single');
    dataDTMBtest = fread(fidDTMBtest,4e5,'single=>single');
    X_test(1:200 , :,ii) = reshape(dataFMtest , 200,2000);
    X_test(201:end,:,ii) = reshape(dataDTMBtest,200,2000);
    Y_test(:,ii) = [str2double(fileFMtest(ii).name(5:7)) str2double(fileFMtest(ii).name(9:11))];
    fclose(fidFMtest);
    fclose(fidDTMBtest);
end
Y_test = Y_test/10;
radioMap.Xmean = double(squeeze(mean(X_train,2)));
% radioMap.Xvar  = double(squeeze(var(X_train,0,2)));
radioMap.Y     = Y_train;
validData.X = double(reshape(X_valid,400,500*length(fileFM)));
validData.Y = kron(Y_valid,ones(1,500));
testData.X  = double(reshape(X_test ,400,2000*length(fileFMtest)));
testData.Y  = kron(Y_test,ones(1,2000));
% save data.mat radioMap validData testData
% save Xtrain.mat X_train
