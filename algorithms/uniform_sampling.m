function out = uniform_sampling(in)
% out = uniform_sampling(in)
%
% in is a structure with (at least) the following fields:
% - A, a matrix
% - k, the target rank of the approximation
% - p, the rank of first two partition matrix
% - c, number of columns to select
% - r, number of rows to select
% - q, the number of times to repeat each Nystrom method for each number of
%  column samples
%
% out is a structure with the following fields:
%  - cidx, c*q matrix represents the column index we choose for each
%  iteration
%  - ridx, r*q matrix represents the row index we choose for each
%  iteration
%  - sigma_k: 1*q vector represents the kth singular value of
%  reconstruction matrix for each iteration
%  - froerr: 1*q vector represents the error in frobenius norm of
%  reconstruction matrix for each iteration
%  - froerr_k: 1*q vector represents the error in frobenius norm of
%  truncated rank-k reconstruction matrix for each iteration
%  - specerr: 1*q vector represents the error in spectral norm of
%  reconstruction matrix for each iteration
%  - specerr_k: 1*q vector represents the error in spectral norm of
%  truncated rank-k reconstruction matrix for each iteration
%  - construct_time: 1*q vector represents the time to choose columns and rows
%  - metric_computing_time: 1*q vector represents the time to compute
%  different metrics


[m,n] = size(in.A);

out.cidx = zeros(c,in.q);
out.ridx = zeros(r,in.q);

out.sigma_k = zeros(1,in.q);
out.froerr = zeros(1,in.q);
out.froerr_k = zeros(1,in.q);
out.specerr = zeros(1,in.q);
out.specerr_k = zeros(1,in.q);

out.construct_time = zeros(1,q);
out.metric_computing_time = zeros(1,q);

for iter=1:in.q
    tic
        permutation = randperm(n);
        out.cidx(:,iter) = permutation(1:c);
        C = in.A(:,cidx);
        permutation = randperm(m);
        out.ridx(:,ridx) = permutation(1:r);
        R = in.A(ridx,:);
    out.construct_time(1,iter) = toc;
    
    tic
        [Qc,~] = qr(C,0);
        [Qr,~] = qr(R',0);
    
        B = Qc'*in.A*Qr;
        CUR = Qc*B*Qr';
        [Ub,Sb,Vb] = svds(B,in.k);
        Bk = Ub*Sb*Vb';
        CUR_k = Qc*Bk*Qr';
    
        residual = in.A-CUR;
        residual_k = in.A - CUR_k;
    
        out.sigma_k(1,iter) = Sb(end,end);
        out.froerr(1,iter) = norm(residual,'fro');
        out.froerr_k(1,iter) = norm(residual_k,'fro');
        out.specerr(1,iter) = svds(residual,1);
        out.specerr_k(1,iter) = svds(residual_k,1);
        
        %out.trerr(1,iter) = trace(sqrt(residual*residual'));
        %out.trerr(2,iter) = trace(sqrt(residual_k*residual_k'));
        
    out.metric_computing_time(1,iter) = toc;

end

end


