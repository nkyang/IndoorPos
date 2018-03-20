function coaRe = coarsePos(rMap,tData)
% X_train_mean = double(radioMap.X_train_mean);
% X_test = double(X_test);
 K = 8;
% FPindex = FPselect(X_train_mean); 
FPindex = 1:size(rMap.Xmean,1);
coaRe.pos = zeros(size(tData.Y));
coaRe.err = zeros(size(tData.Y(1,:)));
coaRe = repmat(coaRe,[1,K]);
coaRe(1).dists = zeros(size(rMap.Xmean,2),size(tData.X,2));
coaRe(1).index = zeros(K,size(tData.X,2));

for i = 1:size(tData.X,2)
    dists = distCal(rMap.Xmean,tData.X(FPindex,i));
    [dist,neighbors] = mink(dists,K);
    weight = 1./dist;
    for j = 1:K
        selWeight = weight(1:j)./(sum(weight(1:j)));
        posResult = sum(bsxfun(@times,rMap.Y(:,neighbors(1:j)),selWeight),2);
        coaRe(j).pos(:,i) = posResult;
        coaRe(j).err(i) = norm(posResult - tData.Y(:,i));
        coaRe(j).index(:,i) = neighbors(1:j)';
    end
    
    coaRe(1).dists(:,i) = dists;
end
end
%% È¡K½üÁÚ
function dists = distCal(X_train,X_test)
dist = bsxfun(@minus,X_train,X_test);
dists = sqrt(sum(dist.^2));
% weight = 1./dists;
end
function FPindex = FPselect(X_train_mean)   
signalMean = mean(X_train_mean,2)';
if size(X_train_mean,1) == 200 
    if max(signalMean) > -70
        foundSignal = find(signalMean>-82);
    else
        foundSignal = 62:138;
    end
else
    foundSignal = [find(signalMean(1:200)>-82), 262:338];
end
%     FP = var(X_train_mean(foundSignal,:),0,2);%./var(X_train_var(foundSignal,:),0,2);
%     [~,FPindex] = maxk(FP,50);
    FPindex = foundSignal;%(FPindex);
end
% exult poaching moon tsunami useful mechanic legion pinched fidget pairing until mayor pinched
% 46v3KMDBUyGV9YAKDkSqKSThbsfjwEZ53Pc5dgh99mjvQfwxjJdvGfyaRrU5Es4oohH6aQy76458GZRB62b38TtA5HjPFzq