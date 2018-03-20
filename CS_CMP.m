function [theta] = CS_CMP(y,A)
%UNTITLED6 此处显示有关此函数的摘要
%   此处显示详细说明
[y_rows,y_columns] = size(y);
if y_rows<y_columns
    y = y';%y should be a column vector
end
[M,N] = size(A);%传感矩阵A为M*N矩阵
theta = zeros(N,1);%用来存储恢复的theta(列向量)
r_n = y;%初始化残差(residual)为y
temp = (A*A')^(-1);
f = @ (x) (x'*temp*x).^(-0.5);
for ii = 1:N
    diagEle(ii) = f(A(:,ii));
end
delta = diag(diagEle);
while norm(r_n)>1e-1
    g = delta*A'*temp*r_n;
    [~,pos] = max(abs(g));
    c = delta(pos,pos)*g(pos);
    theta(pos) = theta(pos) + c;
    r_n = y - A*theta;
end

