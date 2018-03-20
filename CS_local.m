function [calPos,posErr] = CS_local(X_train,X_test,truePos)
%% 将采样点序号转换为坐标
posIndex = posMap();

%% 用来定位的FM频点
FM  = [87.8 88.3 88.5 91.1 92.1 92.5 93.8 95 95.5 96.2 96.6 97.2 97.7 ...
    98 99 99.6 100.5 101.4 102.9 103.7 104.6 105.2 105.4 106.8];
% FM = [87.8 91.1 92.1 96.2 98 99 101.4 104.6 106.8];
FM_index = int16((FM - 86.9)*10);
 FM_index = 1:200;
% FM_index = [FM_index 262:338];
FM_index = FM_index(randperm(numel(FM_index)));
X_train = mean(X_train,3)';
X_train = double(X_train(FM_index,:));
% X_train(:,29:32) = X_train(:,29:32)+7;
%% 生成传感矩阵Q 正交后为T
[T, Q] = preOrth(X_train);
calPos = zeros(2,size(X_test,2));
X_test = double(X_test(FM_index,:));
posErr = zeros(5,size(X_test,2));
%% 压缩感知定位
for i = 1:size(X_test,2)
    zM = T * X_test(:,i);
    alpha = omp(zM,Q,3);
%      alpha = abs(alpha);
    %% 粗定位
    [alpha ,index] = sort(alpha, 'descend');
    for j = 1:5
        a = alpha(1:j);
        b = index(1:j);
        posProb = a/sum(a);
        pos_result = bsxfun(@times,posIndex(:,b),posProb');
        calPos(:,i) = sum(pos_result,2);
        posErr(j,i) = norm(calPos(:,i) - truePos(:,i));
    end
    %% 精定位
%     newIndex = subIndex(calPos(:,i));
%     [Tn , Qn ] = preOrth (X_train(:,newIndex));
%     zM_new = Tn * X_test(:,i);
%     alpha = omp(zM_new,Qn,4);
% %     alpha =abs(alpha);
%     [alpha ,index] = sort(alpha, 'descend');
%     for j = 1:4
%         a = alpha(1:j);
%         b = index(1:j);
%         posProb = a/sum(a);
%         pos_result = bsxfun(@times,posIndex(:,newIndex(b)),posProb');
%         calPos(:,i) = sum(pos_result,2);
%         posErr(j,i) = norm(calPos(:,i) - truePos(:,i));
%     end
end
end

function posIndex = posMap( )
X = [1 2 3 4];
X = repmat(X,[1,11]);
Y = kron(1:11, ones(1,4));
posIndex =cat(1,X,Y);
end

function newIndex = subIndex(pos)
ind1 = 4*floor(pos(2)-3)+1;
ind2 = 4*floor(pos(2)+3);
newIndex = ind1:ind2;
newIndex = newIndex(newIndex>0 & newIndex<45);
end
function [T , Q ] = preOrth(Xn)
R = eye(size(Xn,1))*Xn;
Q = orth(R')';
T = Q*pinv(R);
end


