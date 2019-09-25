function [X,D]=jeig(A,B,srtstr);
L=chol(B,'lower');
G=inv(L);
C=G*A*G';
[Q,D]=schur(C);
X=G'*Q;

if srtstr,
    d = diag(D);
    [ds,is] = sort(d,'descend');
    
    D = diag(ds);
    X = X(:,is);
end
