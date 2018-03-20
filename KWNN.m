function [calPos,posErr] = KWNN(X_train,X_test,truePos,FM_index)
posIndex = posMap();
%% 用来定位的FM频点
% FM  = [87.8 88.3 88.5 91.1 92.1 92.5 93.8 95 95.5 96.2 96.6 97.2 97.7 ...
%     98 99 99.6 100.5 101.4 102.9 103.7 104.6 105.2 105.4 106.8];
% FM = [87.8 91.1 92.1 96.2 98 99 101.4 104.6 106.8];
% FM_index = int16((FM - 86.9)*10);
FM_index = 1:200;
% FM_index = [FM_index 201:400];
% FM_index = 201:400;
% FM_index = FM_index(randperm(numel(FM_index)));
X_mean = mean(X_train,3)';
X_vari = var (X_train,[],3)';
X_mean = double(X_mean(FM_index,:));
X_vari = double(X_vari(FM_index,:));
calPos  = zeros(2,size(X_test,2));
X_test  = double(X_test(FM_index,:));
posErr  = zeros(5,size(X_test,2));
K = 5;
for i = 1:size(X_test,2)
    [dists,neighbors] = top_K_neighbors( X_mean,X_test(:,i),K);
    for j = 3
        weight = 1./dists(1:j)./(sum(1./dists(1:j)));
        pos_result = bsxfun(@times,posIndex(:,neighbors(1:j)),weight);
        calPos(:,i) = sum(pos_result,2);
        posErr(j,i) = norm(calPos(:,i) - truePos(:,i));
    end
    newIndex = subIndex(calPos(:,i));
    [Tn , Qn ] = preOrth (X_mean(:,newIndex));
    zM_new = Tn * X_test(:,i);
    alpha = BP_linprog(zM_new,Qn);
%      alpha =abs(alpha);
    [alpha ,index] = sort(alpha, 'descend');
    for j = 1:4
        a = alpha(1:j);
        b = index(1:j);
        posProb = a/sum(a);
        pos_result = bsxfun(@times,posIndex(:,newIndex(b)),posProb');
        calPos(:,i) = sum(pos_result,2);
        posErr(j,i) = norm(calPos(:,i) - truePos(:,i));
    end
end
end
%% 采样点序号转坐标
function posIndex = posMap( )
X = [1 2 3 4];
X = repmat(X,[1,11]);
Y = kron(1:11, ones(1,4));
posIndex =cat(1,X,Y);
end
%% 取K近邻
function [dists,neighbors] = top_K_neighbors( X_train,X_test,K )
dist = bsxfun(@minus,X_train,double(X_test));
dist = dist.^2;
dist_array = sum(dist);
[dists, neighbors] = sort(dist_array);
dists = dists(1:K);
neighbors = neighbors(1:K);
end
%% 根据粗定位结果选择参考点
function newIndex = subIndex(pos)
ind1 = 4*floor(pos(2)-3)+1;
ind2 = 4*floor(pos(2)+3);
newIndex = ind1:ind2;
newIndex = newIndex(newIndex>0 & newIndex<45);
end
%%
function freq = fSelect(newIndex,X_mean,X_vari)
    X_mean = X_mean(:,newIndex);
    [~,fIndex]=mink(mean(X_mean,2),20);
    var(X_mean,[],)
    
end
%%
function [T , Q ] = preOrth(Xn)
R = eye(size(Xn,1))*Xn;
Q = orth(R')';
T = Q*pinv(R);
end