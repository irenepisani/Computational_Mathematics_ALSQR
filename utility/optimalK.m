%% Optimal k
%
% Compute the best low rank approsimation error using Truncated
% SVD for the problem (P) according to Eckart-Young theorem or using an
% external solver if regularization is required. 
%
%% Syntax
%
% [opt_loss, opt_A, opt_factor_norms ] = optimalK (A, k, lambda_u, lambda_v)
%
%% Description
% 
% Given the matrix A and the desired rank K, solve the low rank
% approximation problem using MatLab implementation of SVD, and truncating 
% it to its k-th values, or, if (P) is regularized, calling an external solver.
%
% Compute  M as the approximation of A, and obtain the optimal error by
% computing the Frobenius norm of the difference between M and A.
%
%% Parameters 
% 
% A: The target initial matrix with dimension m, n.
%
% k: the desired rank to which you want to approximate A with k < min(m, n)
%
% lambda_u, lambda_v: regularization coefficients for the two factors U and
%   V. If they are passed optimal solution is calculated with the
%   Optmiziation Toolbox instead of with SVD. 
% 
%% Examples
%
% A = randn(500, 250);
% k = 100;
% 
% error = optimalK(A, k)
% 
% [err, A_start] = optimalK(A, k, 0.1, 0.1)
%
%% ------------------------------------------------------------------------

function [error, M, factors_norms] = optimalK (A, k, lambda_u, lambda_v)


if nargin < 3 || ( lambda_u == 0 && (nargin == 3 || lambda_v == 0))

    % compute SVD
    [U, S, V] = svd(A);
    
    % obtain Truncated SVD
    U = U(:, 1:k);
    S = S(1:k,1:k);
    V = V(:, 1:k);
    
    % Compute approximation of A 
    M = U*S*V';
    
    % Compute optimal error
    error = norm(A-M, "fro");
    factors_norms = [];

else
    % If we seek the regularized optimal solution, idea is to use a more
    % reliable solver like the matlab "optimproblem" toolbox. 

    [U,V,error] = ExternalSolver(A, k, lambda_u, lambda_v);

    M = U*V';
    
    factors_norms = [norm(U, "fro"), norm(V,"fro")];
end





