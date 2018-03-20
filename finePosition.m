function fineRe = finePosition(coaRe,rMap,tData)

fineRe = coaRe;
fineRe = repmat(fineRe,[1 8]);
% FPindex = 1:size(rMap.Xmean,1);

for i = 1:size(tData.X,2)
    RPindex = RPselect(coaRe.index(:,i),rMap.Y);
    FPindex = FPselect(rMap.Xmean(:,RPindex),rMap.Xvar(:,RPindex));
    zM = tData.X(FPindex,i);
    Q = rMap.Xmean(FPindex,RPindex);
    alpha = pinv(Q)*zM;
%     [T,Q] = preOrth(rMap.Xmean(FPindex,RPindex));
%     zM = T * tData.X(FPindex,i);
%     alpha = l1eq_pd(Q'*zM,Q,[],zM,1e-3*norm(zM));
%     alpha = CS_OMP(zM,Q,8);
    for j = 1:8
        index = find(alpha>0.1*(j-4));
        posProb = alpha(index)/sum(alpha(index));
        posResult = bsxfun(@times,rMap.Y(:,RPindex(index)),posProb');
        fineRe(j).pos(:,i) = sum(posResult,2);
        fineRe(j).err(i) = norm(fineRe(j).pos(:,i) - tData.Y(:,i));
    end
end
end
%% 根据粗定位结果确定精定位所需参考点
function RPindex = RPselect(index,Y_train)
RPindex = [];
for ii = 1:2
    dist = bsxfun(@minus,Y_train(:,index(ii)),Y_train);
    dist = dist.^2;
    dist = sqrt(sum(dist));
    RPindex = [RPindex find(dist<4)];
end
end
%% 根据参考点确定精定位定位所需频点
function FPindex = FPselect(X_train_mean,X_train_var)   
signalMean = mean(X_train_mean,2)';
if size(X_train_mean,1) == 200 
    if max(signalMean) > -70
        foundSignal = find(signalMean>-82);
    else
        foundSignal = 62:138;
    end
else
    foundSignal = [find(signalMean(1:200)>-82), 263:338];
end
%     FP = var(X_train_mean(foundSignal,:),0,2)./var(X_train_var(foundSignal,:),0,2);
%     [~,FPindex] = maxk(FP,15);
    FPindex = foundSignal;%(FPindex);
end
%% 预正交化
function [T , Q ] = preOrth(Xn)
Q = orth(Xn')';
T = Q*pinv(Xn);
end